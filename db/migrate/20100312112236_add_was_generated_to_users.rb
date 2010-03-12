class AddWasGeneratedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :was_generated, :boolean, :default => false
  end

  def self.down
  end
end
