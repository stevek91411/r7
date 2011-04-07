class CreateClassLists < ActiveRecord::Migration
  def self.up
    create_table :class_lists do |t|
     t.string :school_id 				  
     t.string :grade                  
     t.string :class_id                 
     t.timestamps
    end
  end

  def self.down
    drop_table :class_lists
  end
end
