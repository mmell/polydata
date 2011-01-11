# it's up to the local application to enforce security
# it MUST verify polydata_authority is the current Requesting Authority
class PolydataCache < ActiveRecord::Base

  ExpiresMinutesDefault = 24 * 60 # FIXME some requests want to exire more quickly
  ActionMinor = { :xml_v2 => 'xml$v2' }
  ParentPCIDRegExp = /\A(.+\/\(\d+)/

  belongs_to :polydata_authority # the Requesting Authority
  has_many :polydata_cached_canonical_ids, :dependent => :delete_all # delete_all prevents the blocked recursion using :destroy
  
  validates_presence_of :polydata_authority_id
  validates_numericality_of :polydata_authority_id, :allow_nil => true # requester is anonymous

  before_save :set_expires

  def validate
    errors.add(:expires_on, "Cache expired on #{self.expires_on}" ) if self.expired?
    super
  end

  def expired?
    !self.new_record? and self.expires_on < Time.now
  end
  
  def set_expires
    logger.debug("PolydataCache about to set_expires()")
    self.expires_on = Time.now + ExpiresMinutesDefault.minutes - rand( ExpiresMinutesDefault / 24.0 ).minutes # randomize expiration to distribute the ttl
  end
  
  def self.get_cache_request(opts = {})
    polydata_request = opts[:polydata_request]
    polydata_request = Polydata::Request.decode(polydata_request) unless polydata_request.is_a?(Polydata::Request)
    if polydata_request.action.index(/\A\$get/)
      found = find(:first, :conditions => "request='#{polydata_request.to_s}'", :include => :polydata_cached_canonical_ids)
      if found 
        if !opts[:refresh] and found.valid?
          found.update_attribute(:request_count, found.request_count + 1)
          case polydata_request.action_minor
          when ActionMinor[:xml_v2]
            return found.polydata_cached_canonical_ids.map { |e| e.instance_parsed } if found.polydata_cached_canonical_ids.size > 0
          else
            return found.result
          end
        end
        found.destroy
      end
    end

    result = yield

    if Polydata.response_valid?(result)
      if polydata_request.action.index(/\A\$get/)
        case polydata_request.action_minor
        when ActionMinor[:xml_v2]
          parsed = Polydata::XmlV2.parse( result ) # Q: why didn't we Marshal.dump on the Authority server? 
            # A: because Marshal minor version must match on client and that's unlikely
        else 
          parsed = nil
        end
        
        begin
          polydata_cache = PolydataAuthority.authority_for(polydata_request.authority_cid).polydata_caches.create!(
          :request => polydata_request.to_s, 
          :result => (parsed ? nil : result), # don't save result if we have parsed. It might be too large
          :action_minor => polydata_request.action_minor,
          :requester_cid => polydata_request.requester_cid
          )
        rescue StandardError => err
          logger.error("PolydataCache save of #{polydata_request.to_s} failed with #{err}")
        end
        if parsed # when ActionMinor[:xml_v2]
          parsed.each { |e| 
            polydata_cache.polydata_cached_canonical_ids.build( 
              :polydata_canonical_id => e.canonical_id,  # e.g. @llli*sys/(12345/12347)
              :instance_parsed => e
            )
          } 
          polydata_cache.save
        end
      else
        # result of $create, $update, $set, $delete is a list of polydata_canonical_ids
        prune_cache(result.sub(/\A\$ids /, '').split(',')) 
      end
    end
    (parsed.nil? ? result : parsed)
  end
  
  def self.cache_get_polydata(opts = {})
    get_cache_request(opts) { Polydata::polyxri_get( opts ) }
  end
  
  def self.cache_post_polydata(opts = {})
    get_cache_request(opts) { Polydata::polyxri_post( opts ) }
  end
  
  def self.prune_cache( altered_pcids ) 
    altered_pcids.each { |e|
      begin
        parent = ParentPCIDRegExp.match(e)[1]
        PolydataCachedCanonicalId.destroy_all("polydata_canonical_id like '#{parent}/%' or polydata_canonical_id = '#{parent})'")
      rescue StandardError => err
        logger.debug("self.prune_cache failed with #{err}")
      end
    }
#    destroy_all("request like '#{polydata_request.authority_cid}/(#{polydata_request.type.segments[0].query_path}%'")
  end
  
end
