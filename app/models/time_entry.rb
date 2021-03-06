require 'contracts'

class TimeEntry < ApplicationRecord
  include Contracts::Core
  include Contracts::Builtin
    
  belongs_to :user

  validates :start_time, presence: true
  validates :end_time, presence: true, if: ->{ manual_creation? || !end_time_was.nil? }
  validates :description, length: {maximum: 250}
  validate :start_time_is_before_end_time, unless: ->{ end_time.nil? || start_time.nil? }
  validate :start_time_does_not_overlap_with_existing_time_entries, unless: ->{ start_time.nil? }
  validate :end_time_does_not_overlap_with_existing_time_entries, unless: ->{ end_time.nil? }
  validate :does_not_overlap_with_active_time_entry, unless:  ->{ end_time.nil? || start_time.nil? }
  validate :does_not_include_existing_time_entry, unless: ->{ end_time.nil? || start_time.nil? }

  class << self
    Contract None => CustomTypes::ActiveRecordRelationOf[TimeEntry]
    def active
      where('end_time IS NULL')
    end

    Contract Or[Date, CustomTypes::DateString] => CustomTypes::ActiveRecordRelationOf[TimeEntry]
    def recorded_on_date(date)
      where('end_time IS NOT NULL and DATE(start_time) = ?', date)
    end

    Contract HashOf[last: CustomTypes::PosInt] => HashOf[String, String]
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

  Contract None => CustomTypes::PosInt
  def total_time 
    (end_time - start_time).to_i
  end

  Contract None => true
  def set_manual_creation
    @manual_creation = true
  end

  Contract None => Bool
  def manual_creation?
    @manual_creation ||= false
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

  def does_not_include_existing_time_entry 
    scope = TimeEntry
    .where(user: user)
    .where("start_time >= :start_time and end_time <= :end_time", start_time: start_time, end_time: end_time)
    scope = scope.where.not(id: id) unless new_record?
   
    if scope.exists?
      errors.add(:base, :invalid, message: "Time entry cannot include time period of an existing time entry")
    end
  end


  def does_not_overlap_with_active_time_entry
    scope = TimeEntry
    .where(user: user)
    .active
    .where("start_time <= :start_time or start_time <= :end_time", start_time: start_time, end_time: end_time)
    scope = scope.where.not(id: id) unless new_record?

    if scope.exists?
      errors.add(:base, :invalid, message: "Time entry cannot overlap with the start of the ative time entry nor it can be in the future if time tracker is active")
    end
  end
end