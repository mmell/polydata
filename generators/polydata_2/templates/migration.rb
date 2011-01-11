class AddPolydataCacheCounter < ActiveRecord::Migration

  def self.up
    add_column(:polydata_caches, :request_count, :integer, :default => 1)
    add_column(:polydata_caches, :requester_cid, :string)
  end

  def self.down
    remove_column(:polydata_caches, :request_count)
    remove_column(:polydata_caches, :requester_cid)
  end

end
