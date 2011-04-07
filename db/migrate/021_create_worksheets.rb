class CreateWorksheets < ActiveRecord::Migration
  def self.up
    create_table :worksheets do |t|
 	  t.column :name, 						:string     
   	  t.column :user_id, 					:integer  # the user who created the worksheet
      t.column :school_id, 					:string  # set if the user is a teacher
      t.column :grade, 						:string  
      t.column :data, 		          	 	:text  # a list of TopicGroup:TopicId value pairs
      t.timestamps
      t.timestamps
    end
  end

  def self.down
    drop_table :worksheets
  end
end
