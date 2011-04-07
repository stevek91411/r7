class CreateAgcommisions < ActiveRecord::Migration
  def self.up
    create_table :agcommisions do |t|
      t.column :commision_percentage,  	   :integer,:default => 0  # percent 1 -100 
      t.column :commision_type,            :string   # agent, parent
      t.column :commision_cents,      	   :integer,:default => 0  # commision membership cost     
      t.column :agent_payment_method,  	   :string  # cheque     
      t.column :agent_payment_date,  	   :date    
      t.column :agent_payment_detail,  	   :string  # cheque number or similar    
      t.column :agent_name,  	   		   :string  #     
      t.column :agent_id,  	   	   		   :string  #     
      t.column :agent_login,  	   	   	   :string  #   
      t.column :superagent_id,             :integer       # agent who signed this agent up  
      
      # the party can be a parent or an agent        
      t.column :party_status,              :string, :default => "?"  # for a parent-commision -  firstMonth, toPay, paid
      t.column :party_payment_date,        :date  #  the date of the yearly payment
      t.column :party_id,                  :integer   
      t.column :party_login,               :string   
      t.column :party_name,                :string 
      t.column :party_payment_amount_cents, :integer, :default => 0   

	  # parent specific fields
      t.column :parent_membership_expires, :date  #  when the membership expires
      t.column :parent_first_month_expires,:date  #  when the membership expires
      t.timestamps
    end
  end

  def self.down
    drop_table :agcommisions
  end
end
