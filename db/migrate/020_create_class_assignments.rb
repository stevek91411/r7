class CreateClassAssignments < ActiveRecord::Migration
  def self.up
    create_table :class_assignments do |t|
      t.column :assigned_by,               :integer   # id of teacher or parent 
      t.column :assignment_id,             :integer  
      t.column :worksheet_name,           :string  
      t.column :assignment_grade,          :string
      t.column :assignment_class_id,       :string
      t.column :school_id,                 :string	
      t.column :assigned_on,       		   :date  #  when the assignemt expires
      t.column :due,       		   		   :date  #  when the assignemt expires
      t.column :status,                    :string # new, started, completed, expired
      t.column :data, 		          	   :text  # a list of TopicGroup:TopicId value pairs
      t.timestamps
      t.timestamps
    end
  end

  def self.down
    drop_table :class_assignments
  end
end
