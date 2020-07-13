require "rails_helper"

feature "user deletes time entry", js: true, type: :feature do
  before(:each) do
    Timecop.freeze(Time.new(2020, 5, 4, 19, 0, 0))
  end
  after(:each) do
    Timecop.return
  end

  scenario "removes time entry from list" do
    user = create(:user)
    time_entry = create(
      :time_entry,
      user: user,
      start_time: Time.new(2020, 5, 4, 11, 0, 0, Time.zone),
      end_time: Time.new(2020, 5, 4, 14, 0, 0, Time.zone)
    )
    visit root_path( as: user)

    expect(page).to have_css("#total_time", text: "3h 0m 0s")
    within "#time_entry_#{time_entry.id}" do
      accept_confirm(/are you sure/i) do
        click_link "Delete"
      end
    end

    expect(page).not_to have_css("#time_entry_#{time_entry.id}")
    expect(page).to have_css("#total_time", text: "0h 0m 0s")
  end
end