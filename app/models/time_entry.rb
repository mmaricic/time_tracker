class TimeEntry < ApplicationRecord
  belongs_to :user

  validates :start_time, presence: true
  validates :end_time, presence: true, if: ->{ manual_creation? || !end_time_was.nil? }
  validates :description, length: {maximum: 250}
  validate :start_time_is_before_end_time, unless: ->{ end_time.nil? || start_time.nil? }
  validate :start_time_does_not_overlap_with_existing_time_entries, unless: ->{ start_time.nil? }
  validate :end_time_does_not_overlap_with_existing_time_entries, unless: ->{ end_time.nil? }

  class << self
    def active
      where('end_time IS NULL')
    end

    def recorded_on_date(date)
      where('end_time IS NOT NULL and DATE(start_time) = ?', date)
    end

    def total_time_by_day(last:)
      result = select('DATE(start_time) as date, SUM(end_time - start_time) as total_time')
        .where("DATE(start_time) > DATE('#{Date.current}') - #{Arel.sql(last.to_s)}")
        .group('DATE(start_time)')
        .order('DATE(start_time)')
        .to_a
        .map{ |hash| [hash['date'], hash['total_time']] }.to_h

      ((Date.current - (last - 1).days)..Date.current).each do |date|
        result[date] = '00:00:00' unless result.key?(date)
      end
      
      result
        .sort
        .to_h
        .transform_keys{ |k| k.strftime('%a, %-d %b') }
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
      errors.add(:end_time, :invalid, message: "cannot be before or same as start_time")
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
      errors.add(field, :invalid, message: "cannot overlap with an existing time entries")
    end
  end
end