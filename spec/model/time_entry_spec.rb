require 'rails_helper'

describe TimeEntry do
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

end