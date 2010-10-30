require 'rails/generators'
require 'rails/generators'
require 'rails/generators/migration'

# @private
class HierarchyGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  source_root "#{File.dirname __FILE__}/../templates"
  
  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations then
      Time.now.utc.strftime "%Y%m%d%H%M%S"
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end
  
  def copy_files
    migration_template "add_ltree_type.rb", "db/migrate/add_ltree_type.rb"
  end
end
