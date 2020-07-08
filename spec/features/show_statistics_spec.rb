require "rails_helper"

feature "show statistics", type: :feature  do
  before(:each) do
    Timecop.freeze(Time.new(2020, 5, 4, 9, 0, 0, Time.zone))
  end
  
  after(:each) do
    Timecop.return
  end

  scenario "for selected day", js: true do
    user = create(:user)
    yesterday_entry = create(
      :time_entry,
      user: user,
      start_time: Time.new(2020, 5, 3, 12, 0, 0, Time.zone),
      end_time: Time.new(2020, 5, 3, 13, 30, 0, Time.zone),
      description: "Yesterday's entry"
    )
    today_entry = create(
      :time_entry,
      user: user,
      start_time: Time.new(2020, 5, 4, 14, 20, 0, Time.zone),
      end_time: Time.new(2020, 5, 4, 15, 40, 0, Time.zone),
      description: "Today's entry"
    )

    visit statistics_path(as: user)
    
    expect(page).to have_field("preview_date", with: "2020-05-04")
    within dom_id(today_entry) do
      expect(page).to have_content("Today's entry")
    end
    expect(page).not_to have_css(dom_id(yesterday_entry))

    fill_in "preview_date", with: "03/05/2020"
    click_button "Show"

    within dom_id(yesterday_entry) do
      expect(page).to have_content("Yesterday's entry")
    end
    expect(page).not_to have_css(dom_id(today_entry))
  end

  def dom_id(time_entry) 
    "#time_entry_#{time_entry.id}"
  end
end