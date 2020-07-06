class TimeEntriesController < ApplicationController
  before_action :require_login
  before_action :prevent_multiple_active_time_entries, only: [:create]
  
  def new
    @time_entry = current_user.time_entries.new
  end

  def create
    @time_entry = current_user.time_entries.new(time_entry_params)
    @time_entry.set_manual_creation if manual_creation?
    
    if @time_entry.save
      respond_to do |format|
        format.js
        format.html { redirect_to root_path }
      end
    else
      respond_to do |format|
        format.js { head :bad_request }
        format.html { render :new }
      end
    end
  end 

  def edit
    @time_entry = current_user.time_entries.find(params[:id])
  end

  def update
    @time_entry = current_user.time_entries.find(params[:id])
    if @time_entry.update(time_entry_params)
      respond_to do |format|
        format.js
        format.html { redirect_to root_path }
      end
    else
      respond_to do |format|
        format.js { head :bad_request }
        format.html { render :edit }
      end
    end
  end

  private

  def time_entry_params
    params.require(:time_entry).permit(:description, :start_time, :end_time)
  end

  def prevent_multiple_active_time_entries
    if !manual_creation? && current_user.time_entries.active.exists?
      head :bad_request
    end
  end

  def manual_creation?
    params[:time_entry][:manual] || false
  end
end