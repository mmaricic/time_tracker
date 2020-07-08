class HomeController < ApplicationController
  before_action :require_login
  
  def show
    @time_entries_recorded_today = current_user.time_entries.recorded_today.order(:start_time)
    if current_user.time_entries.active.exists?
      @active_time_entry = current_user.time_entries.active.first 
    end
    render :show
  end
end