class CreateSchools < ActiveRecord::Migration
  def self.up
    create_table :schools do |t|
      t.column :school_id, 					:string  # the name of the school
      t.column :contact, 		           	:string
      t.column :email, 			           	:string
      t.column :telephone_home,            	:string
      t.column :telephone_cell,            	:string
      t.column :login_prefix,            	:string
      t.column :student_password,            :string    
      t.column :max_students,   	        :int
      t.column :enrolled_students,          :int
      t.column :status,                    :string  # trial, active, suspended,
      t.column :membership_expires,        :date  #  when the membership expires
      t.timestamps
    end
  end

  def self.down
    drop_table :schools
  end
end
