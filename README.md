Hierarchy
=========

**Use PostgreSQL `LTREE` columns in ActiveRecord**

|             |                                 |
|:------------|:--------------------------------|
| **Author**  | Tim Morgan                      |
| **Version** | 1.0.6 (Nov 27, 2010)            |
| **License** | Released under the MIT license. |

About
-----

The `LTREE` column type is a PostgreSQL-specific type (available from the ltree
extension) for representing hierarchies. It is more efficient than the typical
way of accomplishing hierarchical structures in SQL, the `parent_id` column (or
similar).

This gem lets you use an `LTREE`-utilizing hierarchy in ActiveRecord. Including
this gem in your project gets you a module you can include in your models,
providing an abundance of methods to help you navigate and manipulate the
hierarchy.

Installation
------------

**Important Note:** This gem requires Ruby 1.9+ and Rails 3.0+.

Firstly, add the gem to your Rails project's `Gemfile`:

```` ruby
gem 'hierarchy'
````

Then, run the generator to install the migration:

```` sh
rails generate hierarchy
````

Note that *this migration must precede any tables using `LTREEs`*, so reorder
the migration if you have to.

Usage
-----

Because this gem was hastily extracted from a personal project, it's a little
constraining in how it can be used. (Sorry.) Currently the gem requires that
your table schema have a column named @path@ of type `LTREE`, defined as in the
example below:

```` sql
path LTREE NOT NULL DEFAULT ''
````

Once you've got that column in your model, feel free to include the `Hierarchy`
module:

```` ruby
class Person < ActiveRecord::Base
  include Hierarchy
end
````

You can now define hierarchy by setting a model's `parent`, like so:

```` ruby
person.parent = mother #=> Sets the `path` column appropriately
````

You also have access to a wealth of ways to traverse the hierarchy:

```` ruby
person.children.where(gender: :male)
person.top_level?
Person.treeified #=> returns a traversible tree of all people
````

For more information on what you can do, see the {Hierarchy} module
documentation.

Development
-----------

If you wish to develop for Hierarchy, the first thing you will want to do is get
specs up and running. This requires a call to `bundle install` (obviously) and
setting up your test database.

As you can see in the `spec/spec_helper.rb` file, the specs require that a
PostgreSQL database named `hierarchy_test` exist and be owned by a
`hierarchy_tester` user. Unfortunately I haven't written a way to configure this
(though patches are welcome). So, the following commands should suffice to get
you started:

```` sh
createuser hierarchy_tester # answer "no" to all prompts
createdb -O hierarchy_tester hierarchy_test
````

With those steps done you should be able to run `rake spec` and see the Glorious
Green.
