class CreateTopicActivitySummaries < ActiveRecord::Migration
  def self.up
      create_table :topic_activity_summaries do |t|
      t.integer       :student_id         # from user.id
      t.string        :topic_id           # from topic.id
      t.integer       :total_problems_correct,            :default => 0
      t.integer       :total_problems_wrong,              :default => 0
      t.integer       :total_time_in_sec,                 :default => 0   # the total time for complete & incomplete runs
      t.integer       :total_complete_only_time_in_sec,   :default => 0   # the total time for complete runs
      t.integer       :total_incomplete_runs ,            :default => 0
      t.integer       :total_complete_runs,               :default => 0
      t.integer       :best_time_in_sec,                  :default => -1  # -1 implies not set
      t.string        :result_summary_1                #  topic progress is calculated from the results of the last 5 runs
      t.string        :result_summary_2                # each summary has form  percent_correct:xx seconds_to_complete:yy help_count:zz
      t.string        :result_summary_3              
      t.string        :result_summary_4              
      t.string        :result_summary_5  
      t.string        :grade,     :default => 3                     
      t.timestamps
    end
  end

  def self.down
    drop_table :topic_activity_summaries
  end
end
