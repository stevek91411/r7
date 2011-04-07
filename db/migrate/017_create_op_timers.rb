class CreateOpTimers < ActiveRecord::Migration
  def self.up
    create_table :op_timers do |t|
      t.column :op_name, 					:string  # E.G tEACHERlOGIN
      t.column :start_data, 				:string  # 
      t.column :end_data, 		           	:string
      t.column :status, 			       	:string
      t.column :duration,            		:int		# in 1/10 seconds
      t.column :check_points,				:string
      t.column :start_time,	    			:string  # mmm/dd hh:mm
      t.timestamps
    end
  end

  def self.down
    drop_table :op_timers
  end
end
