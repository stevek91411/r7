class AddPlayerNumberToHighScores < ActiveRecord::Migration
  def self.up
    add_column :high_scores, :player, :string
  end

  def self.down
    remove_column :high_scores, :player
  end
end
