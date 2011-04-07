class CreateGiftCerts < ActiveRecord::Migration
  def self.up
    create_table :gift_certs do |t|
      t.column :status,          			:string, :default =>"Not activiated"   # or redeemed
      t.column :activiation_code,          	:string, :limit => 80 
      t.column :email,                     	:string
      t.column :purchaser_name,            	:string, :limit => 80
      t.column :to,                     	:string, :limit => 80
      t.column :from,                		:string, :limit => 80
      t.column :message,                 	:string 
      t.column :cost_in_dollars,  			:integer, :default => 0   
      t.column :purchace_date,              :datetime
      
      t.column :activiation_date,           :datetime
      t.column :activiation_user_id,        :int
      t.column :activiation_user_name,      :string

      t.timestamps
    end
  end

  def self.down
    drop_table :gift_certs
  end
end
