require 'bundler'
Bundler.require :default, :development
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

system "echo \"CREATE EXTENSION IF NOT EXISTS ltree\" | psql hierarchy_test"

class Model < ActiveRecord::Base
  include Hierarchy
end

RSpec.configure do |config|
  config.before(:each) do
    Model.connection.execute "DROP TABLE IF EXISTS models"
    Model.connection.execute "CREATE TABLE models (id SERIAL PRIMARY KEY, path LTREE NOT NULL DEFAULT '')"
  end
end
