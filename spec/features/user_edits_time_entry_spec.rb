require "rails_helper"

feature "user edits time entry", type: :feature  do
  before(:each) do
    Timecop.freeze(Time.new(2020, 5, 4, 19, 0, 0, Time.zone))
  end

  after(:each) do
    Timecop.return
  end

  scenario "redirects to home page on success" do
    user = create(:user)
    time_entry = create(
      :time_entry,
      user: user,
      start_time: Time.new(2020, 5, 4, 11, 0, 0, Time.zone),
      end_time: Time.new(2020, 5, 4, 14, 0, 0, Time.zone),
      description: "Initial description"
    )

    visit edit_time_entry_path(time_entry, as: user)
    
    fill_in "Description", with: "New description"
    fill_in "End time", with: "2020-05-04T13:37:00"
    click_button "Update"

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("New description")
    expect(page).to have_content("11:00:00")
    expect(page).to have_content("13:37:00")
    expect(page).to have_css("#total_time", text: "2h 37m 0s")
  end

  scenario "fails when entry is invalid" do
    user = create(:user)
    time_entry = create(
      :time_entry,
      user: user,
      start_time: Time.new(2020, 5, 4, 12, 0, 0, Time.zone),
      end_time: Time.new(2020, 5, 4, 14, 0, 0, Time.zone),
      description: "Initial description"
    )

    visit edit_time_entry_path(time_entry, as: user)
    fill_in "End time", with: ""
    click_button "Update"

    expect(page).to have_content("End time can't be blank")
  end
end