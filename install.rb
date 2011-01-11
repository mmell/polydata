require 'fileutils'
FileUtils.copy_file( "#{File.dirname(File.expand_path(__FILE__))}/lib/polydata/config.rb.sample", "#{File.dirname(File.expand_path(__FILE__))}/lib/polydata/config.rb" )
