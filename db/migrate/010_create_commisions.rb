class CreateCommisions < ActiveRecord::Migration
  def self.up
    create_table :commisions do |t|
    end
  end

  def self.down
    drop_table :commisions
  end
end
