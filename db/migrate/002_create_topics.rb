class CreateTopics < ActiveRecord::Migration
  
  def self.up
    create_table :topics do |t|
      t.string :topic_id
      t.integer :no_of_problems
      t.integer :no_of_rows
      t.integer :no_of_cols
      t.string :display_label
      t.string :full_desciption
      t.string :problem_generator_class
      t.string :parameters
      t.integer :max_time_in_sec
      t.string :problem_view_ctl_class
      t.string :help_view_ctl_class
      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
