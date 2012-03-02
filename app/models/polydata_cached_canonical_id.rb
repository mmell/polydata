class PolydataCachedCanonicalId < ActiveRecord::Base
  belongs_to :polydata_cache, :dependent => :destroy

  validates_presence_of :polydata_cache_id
  serialize :instance_parsed
end
