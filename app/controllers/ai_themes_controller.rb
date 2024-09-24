class AiThemesController < ApplicationController
  before_action :set_event, only: %i[ edit update destroy ]
  before_action :set_ai_theme, only: %i[ edit update destroy ]
  def index
    @ai_themes = AiTheme.order(created_at: :desc)
    @event = Event.find(params[:event_id])
  end

  def new
    @ai_theme = AiTheme.new
    @event = Event.find(params[:event_id])
  end

  def edit
  end

  def create
    @ai_theme = AiTheme.new(ai_theme_params)
    @event = Event.find(params[:event_id])
    respond_to do |format|
      if @ai_theme.save
        format.html { redirect_to event_ai_photobooth_ai_themes_path(@event.id, @event.ai_photobooth.id), notice: "AI Theme was successfully created." }
        format.json { render :show, status: :created, location: @ai_theme }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ai_theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @ai_theme.update(ai_theme_params)
        format.html { redirect_to event_ai_photobooth_ai_themes_path(@event.id, @event.ai_photobooth.id), notice: "AI Theme was successfully updated." }
        format.json { render :show, status: :ok, location: @ai_theme }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ai_theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @ai_theme.destroy!

    respond_to do |format|
      format.html { redirect_to event_ai_photobooth_ai_themes_path(@event.id, @event.ai_photobooth.id), notice: "AI Theme was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def pin
    @ai_theme = AiTheme.find(params[:ai_theme_id])
    @event = Event.find(params[:event_id])
    selected_themes = @event.ai_photobooth.selected_themes
    selected_themes.push(@ai_theme.id)
    @event.ai_photobooth.selected_themes = selected_themes
    @event.save

    respond_to do |format|
      format.html { redirect_to event_ai_photobooth_ai_themes_path(@event.id, @event.ai_photobooth.id) }
      format.json { head :no_content }
    end
  end

  def unpin
    @ai_theme = AiTheme.find(params[:ai_theme_id])
    @event = Event.find(params[:event_id])
    selected_themes = @event.ai_photobooth.selected_themes
    selected_themes.delete(@ai_theme.id)
    @event.ai_photobooth.selected_themes = selected_themes
    @event.save

    respond_to do |format|
      format.html { redirect_to event_ai_photobooth_ai_themes_path(@event.id, @event.ai_photobooth.id) }
      format.json { head :no_content }
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_ai_theme
    @ai_theme = AiTheme.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def ai_theme_params
    params.require(:ai_theme).permit(:name, :prompt, :negative_prompt, :styles, :preview, :remove_preview)
  end
end
