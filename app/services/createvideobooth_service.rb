class CreatevideoboothService
  def initialize(session)
    # Initialize Session and Raw model
    @session = session
    @event = Event.find(@session.event_id)
    @raw = @session.raw.first
  end

  def call
    @session.status = "processing"
    @session.save

    # Define a filename
    uuid = SecureRandom.uuid

    slowmo_one_start = @event.videobooth.slowmo_one
    slowmo_two_start = @event.videobooth.slowmo_two
    slowmo_one_end = sprintf("%05.2f", (slowmo_one_start.to_f + 2))
    slowmo_two_end = sprintf("%05.2f", (slowmo_two_start.to_f + 2))

    ffmpeg_setting = "[0:v]trim=1:#{slowmo_one_start},setpts=PTS-STARTPTS[v1];" \
                 "[0:v]trim=#{slowmo_one_start}:#{slowmo_one_end},setpts=PTS-STARTPTS[v2];" \
                 "[0:v]trim=#{slowmo_one_end}:#{slowmo_two_start},setpts=PTS-STARTPTS[v3];" \
                 "[0:v]trim=#{slowmo_two_start}:#{slowmo_two_end},setpts=PTS-STARTPTS[v4];" \
                 "[0:v]trim=#{slowmo_two_end}:12,setpts=PTS-STARTPTS[v5];" \
                 "[v2]setpts=PTS/0.5[slowv];" \
                 "[v4]setpts=PTS/0.5[slowv2];" \
                 "[v1][slowv][v3][slowv2][v5]concat=n=5:v=1:a=0[out2];" \
                 "[2]split[m][a];[m][a]alphamerge[keyed];[out2][keyed]overlay=eof_action=pass[out3];" \
                 "[out3][1]overlay=0:0[out];" \
                 "[3:a]amix=inputs=1[aout]"

    movie = FFMPEG::Media.new(@raw.filename.current_path)
    overlay = @event.videobooth.overlay.current_path
    music = @event.videobooth.music.current_path
    overlay_video = @event.videobooth.overlay_video.current_path

    options = {
      resolution: "1080x1920",
      custom: [ "-i", overlay, "-i", overlay_video, "-i", music, "-filter_complex", ffmpeg_setting, "-map", "[out]", "-map", "[aout]", "-crf", 30, "-r", 30, "-pix_fmt", "yuv420p" ]
    }

    output_path = Rails.root.join("tmp", "#{uuid}.mp4")

    movie.transcode(output_path.to_s, options) do |progress|
      puts "Transcoding... #{(progress * 100).round(2)}%"
      ActionCable.server.broadcast("progress_channel_#{@session.id}", {
        progress: progress
      })
    end

    @export = @session.export.find_or_create_by(filetype: "video")
    @export.filename = File.open(output_path.to_s)
    @export.save

    File.delete(output_path.to_s)
    @raw.destroy!
  end
end
