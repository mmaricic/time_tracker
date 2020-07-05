class TimeEntriesController < ApplicationController
  before_action :require_login
  before_action :prevent_multiple_active_time_entries, only: [:create]

  def create
    @time_entry = current_user.time_entries.new(time_entry_params)
    if @time_entry.save
      respond_to :js  
    else
      head :bad_request
    end
  end 

  def update
    @time_entry = current_user.time_entries.find(params[:id])
    if @time_entry.update(time_entry_params)
      respond_to :js  
    else
      head :bad_request
    end
  end

  private

  def time_entry_params
    params.require(:time_entry).permit(:description, :start_time, :end_time)
  end

  def prevent_multiple_active_time_entries
    if current_user.time_entries.active.exists?
      head :bad_request
    end
  end
end