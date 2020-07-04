class MakeTimeEntryEndTimeNullable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :time_entries, :end_time, true
  end
end
