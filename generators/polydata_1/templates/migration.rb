class AddPolydataCachedCanonicalIds < ActiveRecord::Migration

  def self.up
    add_column(:polydata_caches, :action_minor, :string)
    
    change_column(:polydata_caches, :result, 'LONGTEXT')
    
    create_table :polydata_cached_canonical_ids, :force => true do |t|
      t.integer :polydata_cache_id
      t.string :polydata_canonical_id
    end
    add_column(:polydata_cached_canonical_ids, :instance_parsed, :mediumtext)

  end

  def self.down
    remove_column(:polydata_caches, :action_minor)
    drop_table :polydata_cached_canonical_ids
  end

end
