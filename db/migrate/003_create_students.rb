class CreateStudents < ActiveRecord::Migration
  
  def self.up
    create_table :students do |t|
      t.column :login,                     :string
      t.column :parent_id,                 :integer   
      t.column :email,                     :string
      t.column :first_name,                :string, :limit => 80
      t.column :last_name,                 :string, :limit => 80
      t.column :gender,                    :string      
      t.column :dob,                       :date
      t.column :first_registered,          :date  #  when the membership was started
      t.column :grade,                     :string
      t.column :class_id,                  :string		# when enrolled in a school, e.g Grade 2
      t.column :weekly_target_in_mins,     :integer,  :default => 30 
      t.column :status,                    :string # active, suspended, deleted,
      t.column :school_id, 				   :string
     t.timestamps
    end
  end

  def self.down
    drop_table :students
  end
end
