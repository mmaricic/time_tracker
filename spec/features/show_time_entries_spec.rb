require "rails_helper"

feature "show time entries", type: :feature  do
  before(:each) do
    Timecop.freeze(Time.new(2020, 5, 4, 19, 0, 0))
  end

  after(:each) do
    Timecop.return
  end

  scenario "from today on home page" do
    user = create(:user)
    yesterday_te = create(
      :time_entry,
      user: user,
      start_time: Time.new(2020, 5, 1, 16, 0, 0, Time.zone),
      end_time: Time.new(2020, 5, 1, 17, 0, 0, Time.zone),
    )
    today_first_te = create(
      :time_entry,
      user: user,
      start_time: Time.new(2020, 5, 4, 10, 0, 0, Time.zone),
      end_time: Time.new(2020, 5, 4, 12, 0, 0, Time.zone),
    )
    today_second_te = create(
      :time_entry,
      user: user,
      start_time: Time.new(2020, 5, 4, 12, 30, 0, Time.zone),
      end_time: Time.new(2020, 5, 4, 14, 00, 0, Time.zone),
    )
    today_active_te = create(
      :time_entry,
      user: user,
      start_time: Time.new(2020, 5, 4, 17, 0, 0, Time.zone),
      end_time: nil
    )
    today_another_users_te = create(
      :time_entry,
      user: create(:user),
      start_time: Time.new(2020, 5, 4, 15, 0, 0, Time.zone),
      end_time: Time.new(2020, 5, 4, 16, 0, 0, Time.zone)
    )

    visit root_path(as: user)
    
    expect(page).to have_css(dom_id(today_first_te))
    within(dom_id(today_first_te)) do
      expect(page).to have_content("10:00:00")
      expect(page).to have_content("12:00:00")
    end
    expect(page).to have_css(dom_id(today_second_te))
    expect(page).not_to have_css(dom_id(today_active_te))
    expect(page).not_to have_css(dom_id(today_another_users_te))
    expect(page).not_to have_css(dom_id(yesterday_te))
  end

  def dom_id(entry)
    "#time_entry_#{entry.id}"
  end
end