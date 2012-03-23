module Polydata

  class Render

    XMLDeclaration = %Q{<?xml version="1.0" encoding="UTF-8"?>
}

    def initialize(opts = {})
      # each instances must respond to #id, #value, #query_path, #children. e.g. Polydata::Instance
      @rendered_instances = (opts[:rendered_instances] or [])
      @opts = opts
    end

    def value_render(instance)
      return '$null' if instance.nil? or instance.value.nil?
      instance.value
    end

    def <<(instance)
      s = render(instance)
      @rendered_instances << s
      s
    end

    def camelize(term, uppercase_first_letter = true)
      string = term.to_s
      if uppercase_first_letter
        string = string.sub(/^[a-z\d]*/) { inflections.acronyms[$&] || $&.capitalize }
      else
        string = string.sub(/^(?:#{inflections.acronym_regex}(?=\b|[A-Z_])|\w)/) { $&.downcase }
      end
      string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{inflections.acronyms[$2] || $2.capitalize}" }.gsub('/', '::')
    end

    def render_collection
      case @opts[:polydata_request].action_minor
      when nil, 'xri', 'list', 'vcard'
        @rendered_instances.join("\n")
      when 'ids'
        @rendered_instances.join(",")
      else
        # e.g. Polydata::Render::Kml is a local/custom site class that subclasses this Polydata::Render
        "Polydata::Render::#{@opts[:polydata_request].action_minor.classify}".constantize.new(
          @opts.merge(:rendered_instances => @rendered_instances)
        ).render_collection
      end
    end
    alias_method :to_s, :render_collection

    def render(instance)
      case @opts[:polydata_request].action_minor
      when nil
        instance.value_for(@opts[:polydata_request].type.flat_query_path)

      when 'xri'
        class << @opts[:controller]
          public :polydata_request_url
        end
        unless @polydata_request
          @polydata_request = @opts[:polydata_request].dup
          @polydata_request.action_minor = nil
          @polydata_request.data = nil
          # FIXME xri should not be cached with the Requester embedded
          #   that change will break a lot of clients
          #            @polydata_request.requester = nil
        end

        @polydata_request.type.last.instance_id = instance.id
        "#{@opts[:controller].polydata_request_url( :only_path => false, :trailing_slash => true )}#{@polydata_request.to_s}"

      when 'list'
        result = ["#{instance.query_path} #{value_render(instance)}"]
        instance.children.each { |k,v|
          result << "#{instance.query_path}/#{k} #{v}"
        }
        result.join("\n")

      when 'ids'
        instance.id

      else # e.g. $get/kvm
        instance.render(:controller => @opts[:controller], :polydata_request => @opts[:polydata_request] )
      end
    end

  end # /class Render

end # /module Polydata
