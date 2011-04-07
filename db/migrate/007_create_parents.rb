class CreateParents < ActiveRecord::Migration
  def self.up
    create_table :parents do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :first_name,                :string, :limit => 80
      t.column :last_name,                 :string, :limit => 80
      t.column :max_no_of_active_students, :integer, :default => 2
      t.column :first_registered,          :date  #  when the membership was started
      t.column :last_payment,              :date  #  the date of the last yearly payment
      t.column :membership_expires,        :date  #  when the membership expires
      t.column :payment_amount,            :integer, :default => 0
      t.column :payment_plan,              :string, :default => "?"
      t.column :register_type,             :string, :default => "pp" # cheque - cq, paypal - pp      
      t.column :discount_code,             :string, :default => "" # the discount code of the signing up rep - the Agent code   
    t.timestamps
    end
  end

  def self.down
    drop_table :parents
  end
end
