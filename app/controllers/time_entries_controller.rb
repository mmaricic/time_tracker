class TimeEntriesController < ApplicationController
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
end