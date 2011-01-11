require "polydata/config.rb"
require "polydata/instance.rb"
require "polydata/key.rb"
require "polydata/render.rb"
require "polydata/request.rb"
require "polydata/type_data.rb"
require "polydata/type_segment.rb"
require "polydata/xml_v2.rb"
  
module Polydata

  # see polydata/config for SEP_TYPE, SEP_PATH

  TimestampRangeSecs = 90 # seconds +/-

  def self.xrd( endpoint )
    #<ProviderID>xri://!!1003!#{LOCAL_RETAILER_ID}</ProviderID>
    sep = %Q{
<Service>
<Type select='true'>#{Polydata::Config::SEP_TYPE}</Type>
<Path select='true'>(#{Polydata::Config::SEP_PATH})</Path>
<URI priority='10' append='qxri'>#{endpoint}</URI>
</Service>
}      
  end
  
  def self.response_valid?(response)
    response.index('$error') != 0  
  end
  
  def self.resolve_cid(xri)
    return xri if AtLinksafe::Iname::is_inumber?(xri)
    resolved = AtLinksafe::Resolver::Resolve.new(xri)
    resolved.canonical_id
  end

  def self.get_public_key( opts = {} )
    # if you're using PolydataCache use this instead:
#    PolydataCache.cache_get_polydata(
#      :polydata_request => self.get_public_key_request(:polydata_request => @polydata_request),
#      :end_point => PolyDataClient[:endpoint]
#    )   
    Polydata::polyxri_get(:polydata_request => self.get_public_key_request( opts ), :end_point => opts[:end_point])
  end

  def self.public_key_request( opts = {} )
    opts[:authority] ||= opts[:polydata_request].requester_cid
    Polydata::Request.new(
      :authority => opts[:authority],
      :type => '+public_key',
      :action => '$get'
    )
  end

  def get_secs_now()
    Time.new.getutc.to_i
  end
  module_function( :get_secs_now)

  def self.check_timestamp(submitted_secs)
    secs_now = Polydata.get_secs_now
    (submitted_secs < (secs_now + Polydata::TimestampRangeSecs)) and (submitted_secs > (secs_now - Polydata::TimestampRangeSecs)) 
  end

  def self.get_auth_token(private_keystr, timestamp = Polydata.get_secs_now)
    # get_auth_token must be posted in post arg. not part of the xri
    # private_keystr must belong to @requester
    # timestamp must be within Polydata::TimestampRangeSecs of server time
    Base64.encode64(Polydata::Key.encrypt(private_keystr, timestamp))
  end
  
  def self.verify_auth_token(public_keystr, token)
    # get_auth_token must be posted in post arg. not part of the xri
    # private_keystr must belong to @requester
    # timestamp must be within Polydata::TimestampRangeSecs of server time
    decrypted_secs = Polydata::Key.decrypt(public_keystr, Base64.decode64(token))
    Polydata.check_timestamp(decrypted_secs.to_i)
  end

  def self.polyxri_get(opts = {})
    AtLinksafe::UriLib::fetch_uri(end_point_uri(opts)).body
  end

  # If this is a POST request then the polydata_request is a POST argument, not in the url
  def self.polyxri_post( opts = {} )
    raise RuntimeError, "Polydata request must include a Requester." if opts[:private_key] and !opts[:polydata_request].requester
    opts[:headers] ||= {}
    opts[:use_ssl] ||= true
    opts[:post] = true
    args = "auth_timestamp=#{CGI::escape( Polydata.get_auth_token(opts[:private_key]) ) }" if opts[:private_key]
    args << "&post_data=#{CGI::escape(opts[:post_data].to_s)}" if opts[:post_data]
    args << "&polydata_request=#{CGI::escape(opts[:polydata_request].to_s)}" 
    AtLinksafe::UriLib.post(
      end_point_uri(opts), args, opts[:headers], opts[:use_ssl], {}
    ).body
  end

  def self.end_point_uri(opts = {})
    opts[:end_point] ||= AtLinksafe::Resolver::ResolveSEPToXRD.new(opts[:polydata_request].authority_cid, Polydata::Config::SEP_PATH).uri
    if !opts[:post]
      opts[:end_point] + CGI::escape(opts[:polydata_request].to_s) 
    else
      opts[:end_point]
    end
  end

end # /module Polydata
