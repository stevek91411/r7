class CreateAgents < ActiveRecord::Migration
  def self.up
    create_table :agents do |t|
      t.column :login,                      		:string
      t.column :first_name,                			:string, :limit => 80
      t.column :last_name,                 			:string, :limit => 80
      t.column :address1,                 			:string, :limit => 80
      t.column :address2,                 			:string, :limit => 80
      t.column :city,                 				:string, :limit => 80
      t.column :state,                 				:string, :limit => 80
      t.column :zipcode,                 			:string, :limit => 8
      t.column :email,                     			:string
      t.column :telephone_home,            			:string
      t.column :telephone_cell,            			:string
      t.column :payment_method,            			:string  # paypal or check
      t.column :registered,          				:date  #  when the agent  started
      t.column :agent_code,                			:string, :default => "?"  # used by parent when signing up
      t.column :membership_discount,                :integer, :default => "0"  # dollar discount
      t.column :parent_commision_percentage,  		:integer,:default => 0  # percent 1 -100 
      t.column :subagent_commision_percentage,		:integer,:default => 0  # percent 1 -100 
      t.column :superagent_id,             			:integer       # agent who signed this agent up  
      t.column :superagent_login,           		:string       # agent who signed this agent up  
      t.timestamps    
    end
  end

  def self.down
    drop_table :agents
  end
end
