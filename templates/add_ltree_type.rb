class AddLtreeType < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION ltree"
  end

  def down
    execute "DROP EXTENSION ltree"
  end
end
