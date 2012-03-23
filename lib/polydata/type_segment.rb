require 'cgi'

module Polydata

  class TypeSegment

    ParentQueryPath = '_' # +supporter/mailing_zip$value=94930/_/email_address
    DataTypes = ['$id', '$v', '$version', '$value', '$modified', '$created', '$position']
    Relations = ['=', '>', '>=', '<', '<=', '$in', '$like'] # $btw,  <>,  ><, $not, !, STARTS-WITH,  AND, OR, NOT, INTERSECTION AND UNION

    ParseRE = Regexp.compile("(.+)(#{DataTypes.map { |e| Regexp.escape(e) }.join('|')})(#{Relations.map { |e| Regexp.escape(e) }.join('|')})(.+)")

    attr_accessor :query_path, :data_type, :relation, :value, :position

    # FIXME position is not encoded. should it be? when?

    def initialize(hsh = {})
      hsh = TypeSegment.parse(hsh) if hsh.is_a?(String)
      raise RuntimeError, "A query path is required." if hsh.nil? or hsh.empty? or hsh[:query_path].nil?
      @query_path, @data_type, @relation, @value = hsh[:query_path], hsh[:data_type], hsh[:relation], hsh[:value]
      nullify_relation if !has_data?
    end

    def is_canonical?
      ( @query_path =~ /\A\d+\z/) == 0
    end

    def has_data?
      (!data_type.nil? and !@relation.nil?) or is_canonical? # and !value.nil?
    end

    def is_parent_query?
      ParentQueryPath == @query_path
    end

    def nullify_relation
      @data_type, @relation, @value = nil, nil, nil
    end

    def data_type
      case @data_type
      when '$v'
        '$version'
      else
        @data_type
      end
    end

    def relation # adding here must match Relations
      @relation
    end

    def instance_id
      if is_canonical?
        @query_path
      elsif ('$id' == data_type and '=' == relation )
        @value
      elsif (@value.kind_of?(Array) )
        @value
      else
        nil
      end
    end

    def instance_id=(id)
      @data_type = '$id'
      @value = id
      if id.kind_of?(Array)
        @relation = '$in'
      else
        @relation = '='
      end
    end

    def value
      @value == '$null' ? nil : @value
    end

    def encode
      if relation == '$in'
        value = @value.is_a?(Array) ? "[#{@value.join(',')}]" : @value
      else
        value = @value
      end
      "#{@query_path}#{data_type}#{relation}#{value}"
    end
    alias_method :encode_segment, :encode
    alias_method :to_s, :encode

    def inspect
      to_hash.inspect
    end

    def to_hash
      {
        :query_path => @query_path,
        :data_type => data_type,
        :relation => relation,
        :value => @value
      }
    end

    def self.parse(segment_str = nil)
      return nil if segment_str.nil? or segment_str.strip == ''
      m = ParseRE.match(segment_str)
      if m
        hsh = {
          :query_path => m[1],
          :data_type => m[2],
          :relation => m[3],
          :value => m[4]
        }
        hsh[:value] = CGI::unescape(hsh[:value]) if hsh[:value]
      else
        hsh = {
          :query_path => segment_str
        }
      end
      hsh
    end
  end # /class TypeData

end # /module Polydata
