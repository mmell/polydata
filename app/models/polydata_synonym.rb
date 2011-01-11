class PolydataSynonym < ActiveRecord::Base
  
  ExpireDays = 30
  
  belongs_to :polydata_authority
  validates_presence_of :polydata_authority_id
  validates_numericality_of :polydata_authority_id

  before_save :set_expires
  before_validation_on_create :insure_authority
  
  def insure_authority
    unless self.polydata_authority_id or self.polydata_authority
      resolved = AtLinksafe::Resolver::Resolve.new(self.synonym)
      logger.debug("resolved.canonical_id #{resolved.inspect}")
#      return nil unless resolved.canonical_id
      self.polydata_authority = PolydataAuthority.find_or_create_by_canonical_id(resolved.canonical_id)
    end
  end
  
  def validate
    errors.add(:expires_on, self.expires_on ) if self.expired?
    errors.add(:synonym, "must be a valid iname: #{self.synonym}" ) unless AtLinksafe::Iname::valid?(self.synonym)
    super
  end
    
  def expired?
    !self.new_record? and self.expires_on < Time.now
  end
  
  def set_expires
    self.expires_on = Time.now + ExpireDays.days
  end
  
  def canonical_id
    self.polydata_authority.canonical_id
  end
  
  def self.authority_for(xri)
    return PolydataAuthority.authority_for(xri ) if AtLinksafe::Iname::is_inumber?(xri)
    ps = PolydataSynonym.find_by_synonym(xri, :include => :polydata_authority )
    if ps
      return ps.polydata_authority if ps.valid?
      ps.destroy
    end
    resolved = AtLinksafe::Resolver::Resolve.new(xri)
    return nil unless resolved.canonical_id
    ps = PolydataAuthority.find_or_create_by_canonical_id(resolved.canonical_id).polydata_synonyms.create!(
      :synonym => xri
    )
    ps.polydata_authority
  end
  
  def <=>(other)
    self.synonym <=> other.synonym
  end

  def to_s
    synonym
  end
end
