class CreateDiscountCodes < ActiveRecord::Migration
  def self.up
    create_table :discount_codes do |t|
      t.column :code,                				:string, :default => "?"  # used by parent when signing up
      t.column :party_type,                			:string, :default => "?"  # agent, parent
      t.column :party_id,                  			:integer   # the parentID or agen tID associated with the discount code
      t.column :party_login,                  		:string   # the parent or agent login associated with the discount code
      t.column :agent_membership_discount,          :integer, :default => "0"  # dollar discount give for an agent sign up
      t.column :parent_membership_price,            :integer, :default => "0"  # dollar cost for a parent referral
      t.timestamps
    end
  end

  def self.down
    drop_table :discount_codes
  end
end
