# Convention: the eponymous column is the $value column
# Supporter.supporter; Role.role; Synonym.synonym

require 'active_support/inflector.rb'

module PolydataInstance
  def query_path
    PolydataInstancesMap.key(self.class.name)
  end

  def self.get_query_path_class(flat_query_path)
    while PolydataInstancesMap[flat_query_path].nil?
      return unless flat_query_path.sub!(/\/\w*\z/, '') # chop the final path segment in place
    end
    instance_model = PolydataInstancesMap[flat_query_path].constantize
  end

  def self.included(klass)
    # thanks http://redcorundum.blogspot.com/2006/06/mixing-in-class-methods.html
    klass.extend(ClassMethods)
  end

  def children
    self.attributes
  end

  def query_method(query_path)
    arr = query_path.split('/')
    if arr.size == 1
      self.to_s
    else
      arr.last
    end
  end

  def value_for(query_path)
    self.send(query_method(query_path))
  end

  module ClassMethods

    def permissioned_instance_ids(permissions)
      permissions.map { |e|
        return :any_all_instances if e.any_all_instances?
        e.instance_id
      }
    end

    def value_query(table_name, segment_query_path, includes)
      "`#{table_name}`.#{segment_query_path.sub(/\A\+/, '').singularize }"
    end

    def polydata_request_to_sql(request_type, owner_conditions)
      conditions, includes, top_level_name = [owner_conditions], [], self.name
      request_type.each { |segment|
        klass = PolydataInstance.get_query_path_class(request_type.flat_query_path(segment))
        includes << klass.table_name.to_sym unless klass.name == top_level_name
        if segment.has_data?
          value = segment.value
          case segment.data_type
          when '$value'
            column = value_query(table_name, segment.query_path, includes)
          when '$id'
            column = "`#{klass.table_name}`.id"
          when '$modified'
            column = "`#{klass.table_name}`.updated_at"
            value = Time.at(value.to_i)
          when '$created'
            column = "`#{klass.table_name}`.created_at"
            value = Time.at(value.to_i)
          end

          case segment.relation # Relations = ['=', '>', '>=', '<', '<=', '$in', '$like']
          when '$in'
            relation = ' in '
            value = value[1,value.size()-2].split(',') # submitted value looks like "[1,2,3]"
          when '$like'
            relation = ' like '
          else
            relation = segment.relation
          end
          conditions[0] << "#{column}#{relation}(?)" # (:value) enables $in queries
          conditions << value
        end
      }
      conditions[0] = conditions[0].join(' and ')
      { :conditions => conditions, :includes => includes.uniq }
    end

    def find_each_instance(request_type)
      conditions_includes = polydata_request_to_sql(request_type, [])
      find_each( :conditions => conditions_includes[:conditions], :include => conditions_includes[:includes] ) { |e| yield e } # .uniq
      return # without this the method returns the class (e.g. Supporter) if nothing to yield
    end

  end

end
