require 'contracts'

module TimeEntryHelper
  include Contracts::Core
  include Contracts::Builtin

  Contract CustomTypes::PosInt => String
  def pp_total_time(seconds)
    hours = seconds / 3600
    mins = seconds / 60 % 60
    secs = seconds % 60

    "#{hours}h #{mins}m #{secs}s"
  end

  Contract CustomTypes::CollectionOf[TimeEntry] => String
  def pp_collection_total_time(time_entries)
    pp_total_time(collection_total_time(time_entries))
  end

  Contract CustomTypes::CollectionOf[TimeEntry] => CustomTypes::PosInt
  def collection_total_time(time_entries)
    time_entries.reduce(0) { |sum, time_entry| sum + time_entry.total_time }  
  end
end