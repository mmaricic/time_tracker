require 'rails_helper'

describe TimeEntriesController, type: :request do
  describe "#create" do
    it "returns bad request if user has active time entry" do
      user = create(:user)
      time_entry = create(
        :time_entry,
        user: user,
        start_time: Time.new(2020, 05, 04, 12, 00, 00, Time.zone),
        end_time: nil
      )

      post time_entries_path(as: user),
        params: { time_entry: { description: 'Test', start_time: '2020-05-04T19:55:10' } },
        headers: { 'Accept' => 'application/javascript' }

      expect(response.status).to eq 400
    end
  end

  it 'requires login' do
    post time_entries_path,
      params: { time_entry: { description: 'Test', start_time: '2020-05-04T19:55:10' } },
      headers: { 'Accept' => 'application/javascript' }

    expect(response.status).to eq 401
  end
end