class AddLtreeType < ActiveRecord::Migration
  def self.up
    cmd = "psql -f `pg_config --sharedir`/contrib/ltree.sql #{ActiveRecord::Base.connection.instance_variable_get(:@config)[:database]}"
    puts cmd
    result = system(cmd)
    raise "Bad exit" unless result
  end

  def self.down
    cmd = "psql -f `pg_config --sharedir`/contrib/uninstall_ltree.sql #{ActiveRecord::Base.connection.instance_variable_get(:@config)[:database]}"
    puts cmd
    result = system(cmd)
    raise "Bad exit" unless result
  end
end
