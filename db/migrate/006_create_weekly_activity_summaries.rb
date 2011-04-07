class CreateWeeklyActivitySummaries < ActiveRecord::Migration
  def self.up
       
    create_table :weekly_activity_summaries do |t|
      t.integer       :student_id         # fom user.id
      t.integer       :week              # 1 - 52
      t.integer       :year               # 8 - ??
      t.date          :start_of_week
      t.integer       :day1,       :default => 0
      t.integer       :day2,       :default => 0
      t.integer       :day3,       :default => 0
      t.integer       :day4,       :default => 0
      t.integer       :day5,       :default => 0
      t.integer       :day6,       :default => 0
      t.integer       :day7,       :default => 0
      t.timestamps
    end
  end

  def self.down
    
    
    drop_table :weekly_activity_summaries
  end
end
