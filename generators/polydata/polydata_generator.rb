class PolydataGenerator < Rails::Generator::NamedBase

  def initialize(runtime_args, runtime_options = {})
    runtime_args << 'add_polydata_cache' if runtime_args.empty?
    super
  end

  def manifest
    record do |m|
      m.migration_template 'migration.rb', "db/migrate", { :migration_file_name => "add_polydata_cache" }
    end
  end

end
