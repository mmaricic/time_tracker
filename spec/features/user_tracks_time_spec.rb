require "rails_helper"

feature "user tracks time" do
  scenario "using dashboard", js: true do
    user = create(:user)
    start_time = Time.new(2020, 5, 4, 10, 0, 0, Time.zone)
    end_time = Time.new(2020, 5, 4, 13, 0, 0, Time.zone)

    Timecop.freeze(start_time)
    visit root_path(as: user) do
      mock_browser_time

      fill_in "time_entry_description", with: "Work"
      click_button "start_timer_btn"
    end
  
    Timecop.freeze(end_time)
    visit root_path(as: user) do
      mock_browser_time

      click_button "stop_timer_btn"
      
      within "#time_entry_1" do
        expect(page).to have_content("Work")
        expect(page).to have_content("10:00")
        expect(page).to have_content("13:00")
      end
    end
    Timecop.return
  end

  context "creating time entry manually" do
    scenario "redirects to home page on success" do
      Timecop.freeze(Time.new(2020, 05, 04))
      user = create(:user)

      visit new_time_entry_path(as: user)
      fill_in "Description", with: "manual test"
      fill_in "Start time", with: "2020-05-04T11:00:00"
      fill_in "End time", with: "2020-05-04T12:00:00"
      click_button "Create"

      expect(page).to have_current_path(root_path)
      within "#time_entry_1" do
        expect(page).to have_content("manual test")
        expect(page).to have_content("11:00:00")
        expect(page).to have_content("12:00:00")
      end

      Timecop.return
    end

    scenario "fails when end time is missing" do
      Timecop.freeze(Time.new(2020, 05, 04))
      user = create(:user)

      visit new_time_entry_path(as: user)
      fill_in "Description", with: "manual test"
      fill_in "Start time", with: "2020-05-04T11:00:00"
      click_button "Create"

      expect(page).to have_content("End time can't be blank")
    end
  end

  def unix_millis
    (Time.now.to_f * 1000.0).to_i
  end

  def mock_browser_time
    page.execute_script("FakeTimer.install({ now: #{unix_millis} })")
  end
end