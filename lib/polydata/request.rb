require 'base64'

module Polydata

  class Request
    attr_accessor :authority, :sep_path, :action_minor, :requester, :data
    attr_reader :type, :action

    def initialize(hsh)
      @authority = hsh[:authority]
      self.type = hsh[:type]
      @action_minor, @requester, @data = hsh[:action_minor], hsh[:requester], hsh[:data]
      self.action = hsh[:action] # might overwrite @action_minor
      @requester = nil if !@requester.nil? and @requester.strip == ''
      raise( RuntimeError, "An authority is required.") unless @authority
      @action = Request.default_action unless @action
    end

    def authority_cid
      @authority_cid ||= Polydata.resolve_cid(@authority)
    end

    def requester_cid
      return nil unless @requester
      @requester_cid ||= Polydata.resolve_cid(@requester)
    end

    def type=(something) # accepts TypeData, string or hash
      @type = something.is_a?(TypeData) ? something : TypeData.new(something)
    end

    def action=(s)
      @action, b = Request.parse_whole_action( s )
      @action_minor ||= b
    end

    def encode_action
      "#{@action}#{@action and @action_minor ? '/' + @action_minor : ''}"
    end

    def to_s
      encode
    end

    def encode
      s = "#{@authority}/(#{@type})" #(#{Polydata::Config::SEP_PATH})/
      s << "/(#{encode_action})" unless (@action.nil? or encode_action == Request.default_action) and @requester.nil? and @data.nil?
      if @requester or @data
        s << "/(#{@requester})"
        s << "/(#{@data})" if @data
      end
      s
    end

    def self.decode(xri)
      hsh = {}
      hsh[:authority], xrisplit = xri.split('/', 2)
      xrisplit.gsub!( /^\(\+polydata\)\//, '') # Regexp.escape # Polydata::Config::SEP_PATH  is optional
#      raise StandardError, "query path not recognized" unless xrisplit[0] == '(' and xrisplit[-1] == ')'

      open_ixs, close_ixs, segments = [0], [], []
      # this is 2-3x faster than (0...xrisplit.length).each { |e|
      while true
        ix = xrisplit.index( '(', open_ixs.last() +1 ) # '(' 40
        break unless ix
        open_ixs << ix
      end

      while true
        last_ix = close_ixs.empty? ? 0 : close_ixs.last
        ix = xrisplit.index( ')', last_ix +1 ) # ')' 41
        break unless ix
        close_ixs << ix
      end

      raise StandardError, "Nesting Mismatch." unless open_ixs.size == close_ixs.size
      last_close_ix = nil
      open_ixs.each_index { |e|
        next if last_close_ix and open_ixs[e] < close_ixs[last_close_ix]
        first_close_ix = nil
        close_ixs.each_index { |ee|
          next if open_ixs[e] > close_ixs[ee]
          first_close_ix ||= ee
          last_open_ix = nil # last open less than value of ee
          (e...open_ixs.size).each { |f|
            break if open_ixs[f] > close_ixs[ee]
            last_open_ix = f
          }
          next if (last_open_ix -e) > (ee - first_close_ix)
          segments << xrisplit[ open_ixs[e] +1, (close_ixs[ee] - open_ixs[e]) -1 ]
          last_close_ix = ee
          break
        }
      }

      hsh[:type] = Polydata::TypeData.new(segments[0])
      hsh[:action] = segments[1]
      hsh[:action_minor] = nil
      hsh[:requester] = segments[2]
      hsh[:data] = segments[3]
      if hsh[:action]
        hsh[:action], hsh[:action_minor] = parse_whole_action(hsh[:action])
      else
        hsh[:action] = self.default_action
      end
      self.new(hsh)
    end

    def self.parse_whole_action(s)
      if s.nil? or s == ''
        [nil, nil]
      else
        s.split('/', 2)
      end
    end

    def self.default_action
      '$get'
    end
  end # /class Request

end # /module Polydata
