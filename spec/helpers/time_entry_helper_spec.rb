require "rails_helper"

describe TimeEntryHelper, type: :helper do
  it "#pp_total_time" do
    total_time_seconds = 44 + 13 * 60 + 2 * 60 * 60

    expect(helper.pp_total_time(total_time_seconds)).to eq("2h 13m 44s")
  end

  it "#pp_collection_total_time" do
    time_entries_collection = [
      create(
        :time_entry,
        start_time: Time.new(2020, 5, 4, 9, 0, 0, Time.zone),
        end_time: Time.new(2020, 5, 4, 10, 30, 0, Time.zone)
      ),
      create(
        :time_entry,
        start_time: Time.new(2020, 5, 4, 11, 0, 0, Time.zone),
        end_time: Time.new(2020, 5, 4, 13, 0, 0, Time.zone)
      ),
      create(
        :time_entry,
        start_time: Time.new(2020, 5, 4, 14, 0, 0, Time.zone),
        end_time: Time.new(2020, 5, 4, 15, 15, 30, Time.zone)
      )
    ]

    result = helper.pp_collection_total_time(time_entries_collection)
    expect(result).to eq("4h 45m 30s")
    end
end