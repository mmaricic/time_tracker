class TimeEntry < ApplicationRecord
  belongs_to :user

  validates :start_time, presence: true
  validates :end_time, presence: true, if: ->{ manual_creation? }
  validates :description, length: {maximum: 250}
  validate :start_time_is_before_end_time, unless: ->{ end_time.nil? || start_time.nil? }
  validate :start_time_does_not_overlap_with_existing_time_entries, unless: ->{ start_time.nil? }
  validate :end_time_does_not_overlap_with_existing_time_entries, unless: ->{ end_time.nil? }

  class << self
    def active
      where('end_time IS NULL')
    end

    def recorded_today
      where('end_time IS NOT NULL and DATE(start_time) = ?', Date.today)
    end
  end

  def total_time 
    (end_time - start_time).to_i
  end

  def set_manual_creation
    @manual_creation = true
  end

  def manual_creation?
    @manual_creation
  end

  private 

  def start_time_is_before_end_time
    if start_time >= end_time
      errors.add(:end_time, :invalid, message: "end_time cannot be before or same as start_time")
    end
  end

  def start_time_does_not_overlap_with_existing_time_entries
    time_does_not_overlap_with_existing_time_entries("start_time", start_time)
  end

  def end_time_does_not_overlap_with_existing_time_entries
    time_does_not_overlap_with_existing_time_entries("end_time", end_time)
  end

  def time_does_not_overlap_with_existing_time_entries(field, value)
    scope = TimeEntry.where(user: user).where("start_time <= :time and end_time >= :time", time: value)
    scope = scope.where.not(id: id) unless new_record?
    if scope.exists?
      errors.add(field, :invalid, message: "#{field} cannot overlap with an existing time entries")
    end
  end
end