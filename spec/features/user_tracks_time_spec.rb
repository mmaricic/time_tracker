require "rails_helper"

feature "user tracks time", type: :feature  do
  context "using dashboard", js: true do
    scenario "successfully starts tracker" do
      user = create(:user)
      start_time = Time.new(2020, 5, 4, 10, 0, 0)
      end_time = Time.new(2020, 5, 4, 13, 0, 0)

      Timecop.freeze(start_time)
      visit root_path(as: user)
      mock_browser_time
      expect(page).to have_css("#total_time", text: "0h 0m 0s")

      fill_in "time_entry_description", with: "Work"
      click_button "Start"
      wait_for_ajax
    
      Timecop.freeze(end_time)
      visit root_path(as: user)
      mock_browser_time

      click_button "Stop"
      wait_for_ajax
    
      expect(page).to have_css("#total_time", text: "3h 0m 0s")
      expect(page).to have_content("Work")
      expect(page).to have_content("10:00")
      expect(page).to have_content("13:00")

      Timecop.return
    end
    
    scenario "fails because there is a time entry that includes current time" do
      user = create(:user)
      time_entry = create(
        :time_entry,
        user: user,
        start_time: Time.new(2020, 5, 4, 8, 0, 0, Time.zone),
        end_time: Time.new(2020, 5, 4, 13, 0, 0, Time.zone)
      )
      current_time = Time.new(2020, 5, 4, 10, 0, 0, Time.zone)
      
      Timecop.freeze(current_time)
      visit root_path(as: user)
      mock_browser_time

      accept_alert(/start time cannot overlap/i) do
        click_button "start_timer_btn"
      end
      expect(page).not_to have_css("#stop_timer_btn")

      Timecop.return
    end
  end

  context "creating time entry manually" do
    before(:each) do
      Timecop.freeze(Time.new(2020, 5, 4, 19, 0, 0, Time.zone))
    end
    after(:each) do
      Timecop.return
    end

    scenario "redirects to home page on success" do
      user = create(:user)

      visit new_time_entry_path(as: user)
      
      fill_in "Description", with: "manual test"
      fill_in "Start time", with: "2020-05-04T11:00:00"
      fill_in "End time", with: "2020-05-04T12:00:00"
      click_button "Create"

      expect(page).to have_current_path(root_path)
      expect(page).to have_content("manual test")
      expect(page).to have_content("11:00:00")
      expect(page).to have_content("12:00:00")
      expect(page).to have_css("#total_time", text: "1h 0m 0s")
    end

    scenario "fails when end time is missing" do
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

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end