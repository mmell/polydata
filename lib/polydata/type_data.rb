module Polydata

  class TypeData < Array

    attr_reader :segments

    def initialize(segments = [])
      add_children(segments) 
    end
    
    def add_children(segments = []) 
      if segments.is_a?(String)
        self.push( *TypeData.parse(segments) )
      elsif segments.is_a?(Hash)
        self << TypeSegment.new(segments)
      elsif segments.is_a?(TypeSegment)
        self << segments
      else # assume Array
        segments.each { |e| add_children(e) } # each might be string, hash, or array
      end
      raise RuntimeError, "A query path is required. #{segments.inspect}" if segments.empty?
      reset
    end

    def reset
      (0...self.size).each { |ix| self[ix].position = ix }
    end

    def has_data?
      self.each { |e| return true if e.has_data? }
    end
    
    def flat_query_path(last_ix = nil )
      last_ix ||= self.size() -1
      last_ix = last_ix.position() if last_ix.is_a?(TypeSegment)
      paths = []
      self.slice(0, last_ix +1).each { |e| 
        if e.is_parent_query?
          paths.pop
        else
          paths << e.query_path
        end
      }
      paths.join('/')
    end
    
    def encode(last_ix = nil )
      last_ix ||= self.size() -1
      last_ix = last_ix.position() if last_ix.is_a?(TypeSegment)
      self.slice(0, last_ix +1).map { |e| e.encode }.join('/')
    end
    alias_method :to_s, :encode

    def child_of(ix = 0 )
      ix = ix.position() if ix.is_a?(TypeSegment)
      ix = ix < (self.size() -1) ? (ix +1) : nil
      return nil unless ix
      self[ix]
    end
    alias_method :child, :child_of

    def parent_of(ix = self.size() -1 )
      ix = ix.position() if ix.is_a?(TypeSegment)
      ix = ix > 0 ? (ix -1) : nil
      return nil unless ix
      self[ix]
    end
    alias_method :parent, :parent_of

    def self.parse(type_str = nil)
      return [] if type_str.nil? or type_str.strip == ''
      type_str.split('/').map { |e| TypeSegment.new(e) }
    end
  end # /class TypeData

end # /module Polydata
