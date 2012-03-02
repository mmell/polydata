class PolydataAuthority < ActiveRecord::Base
  
  has_many :polydata_synonyms, :dependent => :destroy
  has_many :polydata_caches, :dependent => :destroy
  
  validates_format_of :canonical_id, :with => /^[@=]![A-F0-9\.]{2,}/ # actually, I think [A-F0-9\.] is more precise
  validates_uniqueness_of :canonical_id
  validates_presence_of :canonical_id
  
  def synonym
    (self.valid_synonyms.size > 0 ? self.valid_synonyms[0].synonym : canonical_id)
  end
  
  def valid_synonyms
    self.polydata_synonyms.select { |e| 
      if e.valid?
        true
      else
        e.destroy
        false
      end
    }
  end
  
  def <=>(other)
    self.synonym <=> other.synonym
  end

  def self.authority_for(xri)    
    return PolydataAuthority.find_or_create_by_canonical_id(xri, :include => :polydata_synonyms) if AtLinksafe::Iname::is_inumber?(xri)
    PolydataSynonym.authority_for(xri)
  end
    
end
