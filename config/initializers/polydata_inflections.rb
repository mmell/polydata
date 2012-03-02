ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural /(cache)$/i, '\1\2s'
  inflect.singular /(cache)s$/i, '\1'
end
