require "polydata/client.rb"
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

  def self.response_valid?(response)
    response.index('$error') != 0
  end

  def self.resolve_cid(xri)
    return xri if AtLinksafe::Iname::is_inumber?(xri)
    resolved = AtLinksafe::Resolver::Resolve.new(xri)
    resolved.canonical_id
  end

  def self.get_public_key( opts = {} )
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

end
