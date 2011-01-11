class AddPolydataCache < ActiveRecord::Migration

  def self.up
    create_table :polydata_authorities, :force => true do |t|
      t.string :canonical_id
      t.datetime :created_on
      t.datetime :updated_on
    end

    create_table :polydata_synonyms, :force => true do |t|
      t.integer :polydata_authority_id
      t.string :synonym
      t.datetime :expires_on
      t.datetime :created_on
      t.datetime :updated_on
    end

    create_table :polydata_caches, :force => true do |t|
      t.integer :polydata_authority_id
      t.text :request
      t.text :result
      t.datetime :expires_on
      t.datetime :created_on
    end

  end

  def self.down
    drop_table :polydata_authorities
    drop_table :polydata_synonyms
    drop_table :polydata_caches
  end

end
