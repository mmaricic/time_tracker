require "rails_helper"

feature "user tracks time" do
  scenario "using dashboard", js: true do
    user = create(:user)
    start_time = Time.new(2020, 5, 4, 10, 0, 0)
    end_time = Time.new(2020, 5, 4, 13, 0, 0)

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

  def unix_millis
    (Time.now.to_f * 1000.0).to_i
  end

  def mock_browser_time
    page.execute_script("FakeTimer.install({ now: #{unix_millis} })")
  end
end