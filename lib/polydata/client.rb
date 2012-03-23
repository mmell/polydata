module Polydata

  module Client

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
      opts[:end_point] ||= AtLinksafe::Resolver::ResolveSEPToXRD.new(opts[:polydata_request].authority_cid).uri
      if !opts[:post]
        opts[:end_point] + CGI::escape(opts[:polydata_request].to_s)
      else
        opts[:end_point]
      end
    end

  end
end
