require "rails_helper"

feature "user deletes time entry", js: true do
  before(:each) do
    Timecop.freeze(Time.new(2020, 5, 4))
  end
  after(:each) do
    Timecop.return
  end

  scenario "removes time entry from list" do
    user = create(:user)
    time_entry = create(
      :time_entry,
      user: user,
      start_time: Time.new(2020, 05, 04, 11, 00, 00, Time.zone),
      end_time: Time.new(2020, 05, 04, 14, 00, 00, Time.zone)
    )

    visit root_path( as: user)
    within "#time_entry_#{time_entry.id}" do
      accept_confirm(/are you sure/i) do
        click_link "Delete"
      end
    end
      
    expect(page).not_to have_css("#time_entry_#{time_entry.id}")
  end
end