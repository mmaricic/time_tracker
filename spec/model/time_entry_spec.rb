require 'rails_helper'

describe TimeEntry do
  describe '.recorded_today' do
    before(:each) do
      Timecop.freeze(Time.new(2020, 5, 4, 19, 0, 0))
    end

    it 'returns time entries recorded on the current day' do
      yesterday_te = create(
        :time_entry,
        start_time: Time.new(2020, 5, 1, 16, 0, 0),
        end_time: Time.new(2020, 5, 1, 17, 0, 0)
      )
      today_first_te = create(
        :time_entry,
        start_time: Time.new(2020, 5, 4, 10, 0, 0),
        end_time: Time.new(2020, 5, 4, 12, 0, 0)
      )
      today_second_te = create(
        :time_entry,
        start_time: Time.new(2020, 5, 4, 12, 30, 0),
        end_time: Time.new(2020, 5, 4, 14, 0, 0)
      )
      today_active_te = create(
        :time_entry,
        start_time: Time.new(2020, 5, 4, 17, 0, 0),
        end_time: nil
      )

      expect(described_class.recorded_today).to match_array([
        today_first_te,
        today_second_te
      ])
    end
  end

  describe ".active" do
    it "returns time entries that are active" do
      finished_te = create(
        :time_entry,
        start_time: Time.new(2020, 5, 1, 16, 0, 0),
        end_time: Time.new(2020, 5, 1, 17, 0, 0)
      )
      active_te = create(
        :time_entry,
        start_time: Time.new(2020, 5, 2, 11, 0, 0),
        end_time: nil
      )

      expect(described_class.active).to eq([active_te])
    end
  end

  it "validates start time presence" do
    time_entry = build(:time_entry, start_time: nil)
    
    expect(time_entry.valid?).to be false
    expect(time_entry.errors[:start_time]).not_to be_empty
  end

  it "validates description length" do
    time_entry = build(:time_entry, description: "a"*300)

    expect(time_entry.valid?).to be false
    expect(time_entry.errors[:description]).not_to be_empty
  end

  it "validates that start_time is before end_time" do
    time_entry = build(
      :time_entry, 
      start_time: Time.new(2020, 07, 01, 15, 00, 00), 
      end_time: Time.new(2020, 07, 01, 11, 00, 00)
    )

    expect(time_entry.valid?).to be false
    expect(time_entry.errors[:end_time]).not_to be_empty
  end

  it "validates that start_time is not the same as end_time" do
    time_entry = build(
      :time_entry, 
      start_time: Time.new(2020, 07, 01, 15, 00, 00), 
      end_time: Time.new(2020, 07, 01, 15, 00, 00)
    )

    expect(time_entry.valid?).to be false
    expect(time_entry.errors[:end_time]).not_to be_empty
  end

  context "creating time entry manually" do
    it "validates end time presence" do
      time_entry = build(
        :time_entry,
        start_time: Time.new(2020, 07, 01, 14, 00, 00),
        end_time: nil
      )
      time_entry.set_manual_creation

      expect(time_entry.valid?).to be false
      expect(time_entry.errors[:end_time]).not_to be_empty
    end    
  end

  context "time entries overlap" do
    it "start time overlaps with existing time entry" do
      user = create(:user)
      existing_time_entry = create(
        :time_entry,
        user: user,
        start_time: Time.new(2020, 07, 01, 10, 00, 00),
        end_time: Time.new(2020, 07, 01, 12, 00, 00)
      )
      new_time_entry = build(
        :time_entry,
        user: user,
        start_time: Time.new(2020, 07, 01, 11, 00, 00),
        end_time: Time.new(2020, 07, 01, 15, 00, 00)
      )

      expect(existing_time_entry.valid?).to be true
      expect(new_time_entry.valid?).to be false
      expect(new_time_entry.errors[:start_time]).not_to be_empty
    end

    it "end time overlaps with existing time entry" do
      user = create(:user)
      existing_time_entry = create(
        :time_entry,
        user: user,
        start_time: Time.new(2020, 07, 01, 10, 00, 00),
        end_time: Time.new(2020, 07, 01, 12, 00, 00)
      )
      new_time_entry = build(
        :time_entry,
        user: user,
        start_time: Time.new(2020, 07, 01, 07, 00, 00),
        end_time: Time.new(2020, 07, 01, 11, 00, 00)
      ) 

      expect(existing_time_entry.valid?).to be true
      expect(new_time_entry.valid?).to be false
      expect(new_time_entry.errors[:end_time]).not_to be_empty
    end

    it "start time and end time overlap with existing time entries" do
      user = create(:user)
      existing_time_entry = create(
        :time_entry,
        user: user,
        start_time: Time.new(2020, 07, 01, 10, 00, 00),
        end_time: Time.new(2020, 07, 01, 17, 00, 00)
      )
      new_time_entry = build(
        :time_entry,
        user: user,
        start_time: Time.new(2020, 07, 01, 11, 00, 00),
        end_time: Time.new(2020, 07, 01, 15, 00, 00)
      )

      expect(existing_time_entry.valid?).to be true
      expect(new_time_entry.valid?).to be false
      expect(new_time_entry.errors[:start_time]).not_to be_empty
      expect(new_time_entry.errors[:end_time]).not_to be_empty
    end

    it "time entry overlaps with another user's time entry" do
      user_1 = create(:user)
      existing_time_entry = create(
        :time_entry,
        user: user_1,
        start_time: Time.new(2020, 07, 01, 10, 00, 00),
        end_time: Time.new(2020, 07, 01, 17, 00, 00)
      )
      user_2 = create(:user)
      new_time_entry = build(
        :time_entry,
        user: user_2,
        start_time: Time.new(2020, 07, 01, 11, 00, 00),
        end_time: Time.new(2020, 07, 01, 15, 00, 00)
      )

      expect(existing_time_entry.valid?).to be true
      expect(new_time_entry.valid?).to be true
    end
  end

  it 'calculates total time' do
    time_entry = create(
      :time_entry,
      start_time: Time.new(2020, 05, 04, 10, 30, 00),
      end_time: Time.new(2020, 05, 04, 11, 17, 17)
    )

    expect(time_entry.total_time).to eq(47 * 60 + 17)
    expect(time_entry.total_time).to be_an(Integer)
  end
end