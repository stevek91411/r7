class CreateTeachers < ActiveRecord::Migration
  def self.up
    create_table :teachers do |t|
  	  t.column :login,                     :string
      t.column :email,                     :string
      t.column :admin,		  		   	   :string, :default =>"no"
      t.column :first_name,                :string, :limit => 80
      t.column :last_name,                 :string, :limit => 80
      t.column :school_id, 				   :string
      t.column :class_id,                  :string,	:default => ""	# e.g Grade 2
      t.column :first_registered,          :date  #  when the membership was started
      t.column :membership_expires,        :date  #  when the membership expires
      t.column :telephone_home,            	:string
      t.column :telephone_cell,            	:string
      t.timestamps
    end
  end

  def self.down
    drop_table :teachers
  end
end
