module Polydata
  
  # a small class to represent conventional model objects as Polydata Instances
  class Instance 
    attr_accessor :id, :value, :query_path, :children, :parent_id

    def initialize(id, value, query_path, singular = true )
      @id, @value, @query_path, @singular = id, value, query_path, singular
      @children = []
    end
    
    def self.child_method
# failed hack trying to make this work for render_test
    # @query_path.sub('+', '').camelize.demodulize.underscore.to_sym
    end
    
    def self.singular?
      true # hack
    end
    
    # FIXME need method to return child_methods
    def <<(obj)
      obj.parent_id = @id
      @children << obj
    end
    
    def render(opts = {})
      @value
    end
    
    def child_classes
      children.map { |e| e.class }.uniq
    end
    
  end # /class Instance

end # /module Polydata
