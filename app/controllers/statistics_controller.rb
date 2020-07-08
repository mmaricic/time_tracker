class StatisticsController < ApplicationController
  before_action :require_login

  def show
    @time_entries_recorded_on_date = current_user.time_entries.recorded_on_date(preview_date).order(:start_time)
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def preview_date
    @preview_date ||= params.key?(:preview_date) ? params[:preview_date] : Date.current
  end
end