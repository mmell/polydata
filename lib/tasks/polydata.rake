desc "the polydata plugin"
namespace :polydata do

  desc "polydata optimize tables"
  task( :optimize_tables, [] => [:environment]) { |t, args|
    tables = %W{ polydata_authorities polydata_cached_canonical_ids polydata_caches polydata_synonyms }
    tables.each { |e| 
      ActiveRecord::Migration.execute( "optimize table #{e};")
    }
    puts("complete optimize tables [#{tables.join(', ')}]")
  }

  desc "polydata cache"
  namespace :cache do

    desc "PolydataCache.destroy_all"
    task( :clear, [] => [:environment]) do
      puts "cleared #{PolydataCache.destroy_all.size}"
    end

    desc "PolydataAuthority.destroy_all clears authorities, synonyms and caches"
    task( :clear_authorities, [] => [:environment]) do
      puts "cleared #{PolydataAuthority.destroy_all.size}"
    end

      desc "PolydataSynonym.destroy_all"
      task( :clear_synonyms, [] => [:environment]) do
        puts "cleared #{PolydataSynonym.destroy_all.size}"
      end

  end

end
