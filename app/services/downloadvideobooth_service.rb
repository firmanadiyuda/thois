class DownloadvideoboothService
  def initialize(session)
    # Initialize Session and Raw model
    @session = session
    @event = Event.find(@session.event_id)
  end

  def call
    @session.status = "downloading"
    @session.save


    counter = sprintf("%06d", @session.gopro_counter)

    # url = "http://10.5.5.9:8080/videos/DCIM/100GOPRO/GH#{counter}.MP4"
    url = "http://192.168.1.2:8080/GH#{counter}.MP4"
    file_path = "tmp/#{SecureRandom.uuid}.mp4"

    # Membuat koneksi dengan Faraday
    conn = Faraday.new do |faraday|
      faraday.response :logger  # Logging response untuk debugging
      faraday.adapter Faraday.default_adapter
    end

    begin
      # Mendapatkan informasi size file dari header
      response = conn.head(url) do |req|
        req.options.open_timeout = 5  # Timeout untuk membuka koneksi
        # req.options.timeout = 5       # Timeout untuk menunggu respons
      end

      total_size = response.headers["content-length"].to_i
      progress = 0
      overall_received_bytes = 0
      last_received_bytes = 0
      start_time = Time.now

      # Thread untuk menampilkan progres setiap detik
      progress_thread = Thread.new do
        loop do
          current_time = Time.now
          elapsed_time = current_time - start_time

          downloaded_last_second = overall_received_bytes - last_received_bytes
          download_speed = downloaded_last_second / 1.0  # Bytes per second (Bps)
          last_received_bytes = overall_received_bytes

          # Mengonversi speed ke KBps
          download_speed_kbps = download_speed / 1000
          download_speed_mbps = (download_speed_kbps / 1000).round(2)

          total_size_mb = ((total_size / 1000) / 1000).round(1)
          overall_received_mb = ((overall_received_bytes / 1000) / 1000).round(1)

          # puts @session.id
          puts "Progress: #{progress.round(0)}% | #{overall_received_mb}MB/#{total_size_mb}MB | #{download_speed_mbps}MB/s"
          ActionCable.server.broadcast("progress_channel_#{@session.id}", {
            progress: progress
          })
          sleep 1  # Menampilkan progres tiap 1 detik
        end
      end

      File.open(file_path, "wb") do |file|
        # Mendownload file dengan progres
        conn.get(url) do |req|
          req.options.on_data = Proc.new do |chunk, received_bytes, env|
            # Menulis chunk yang diterima ke file
            file.write(chunk)

            # Update progres
            overall_received_bytes += chunk.size
            progress = (overall_received_bytes.to_f / total_size) * 100
          end
        end
      end

      @raw = @session.raw.find_or_create_by(filetype: "video")
      @raw.filename = File.open(file_path)
      @raw.save
      File.delete(file_path)

    rescue Faraday::TimeoutError
      # puts "Request timed out!"
      @session.status = "failed"
      @session.save
      progress_thread.kill

    rescue Faraday::ConnectionFailed => e
      # puts "Connection failed: #{e.message}"
      @session.status = "failed"
      @session.save
      progress_thread.kill

    ensure
      progress_thread.kill
    end
  end
end
