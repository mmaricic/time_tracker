module TimeEntryHelper
  def pp_total_time(seconds)
    hours = seconds / 3600
    mins = seconds / 60 % 60
    secs = seconds % 60

    "#{hours}h #{mins}m #{secs}s"
  end
end