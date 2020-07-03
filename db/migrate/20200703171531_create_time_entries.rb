class CreateTimeEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :time_entries do |t|
      t.timestamp :start_time, null: false
      t.timestamp :end_time, null: false
      t.string :description, limit: 250
      t.references :user, foreign_key: true, index: true
      t.timestamps null: false
    end
  end
end
