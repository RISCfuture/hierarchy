Bundler.require :default, :test
require 'active_support'
require 'active_record'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'hierarchy'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: 'hierarchy_test',
  username: 'hierarchy_tester'
)
system "psql -f `pg_config --sharedir`/contrib/ltree.sql hierarchy_test &>/dev/null"

class Model < ActiveRecord::Base
  include Hierarchy
end

RSpec.configure do |config|
  config.before(:each) do
    Model.connection.execute "DROP TABLE IF EXISTS models"
    Model.connection.execute "CREATE TABLE models (id SERIAL PRIMARY KEY, path LTREE NOT NULL DEFAULT '')"
  end
end
