require "rails_helper"

describe TimeEntryHelper, type: :helper do
  it "#pp_total_time" do
    total_time_seconds = 44 + 13 * 60 + 2 * 60 * 60

    expect(helper.pp_total_time(total_time_seconds)).to eq("2h 13m 44s")
  end
end