class CreateTopicRunResults < ActiveRecord::Migration
  def self.up
    create_table :topic_run_results do |t|
      t.integer   :student_id
      t.string    :topic_id
      t.date    :date_recorded 
      t.time    :time_recorded 
      t.integer   :problems_correct
      t.integer   :problems_wrong
      t.integer   :total_problems
      t.integer   :seconds_to_complete
      t.boolean   :incomplete
      t.integer   :help_count,  :default => 0 
      t.string    :grade,     :default => 3
      t.timestamps
    end
  end


  def self.down
    drop_table :topic_run_results
  end
end
