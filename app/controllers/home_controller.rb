class HomeController < ApplicationController
  before_action :require_login
  
  def show
    @time_entries_recorded_today = current_user.time_entries.recorded_today
    render :show
  end
end