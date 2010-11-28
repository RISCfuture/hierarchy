# @private
module Arel
  # @private
  module Attributes
    # @private
    def self.for_with_psql(column)
      case column.sql_type
        when 'ltree' then String
        else for_without_psql(column)
      end
    end
    unless singleton_class.method_defined?(:for_without_psql)
      singleton_class.send :alias_method, :for_without_psql, :for
      singleton_class.send :alias_method, :for, :for_with_psql
    end
  end
end

require 'hierarchy_generator'
require 'hierarchy/index_path'
require 'hierarchy/node'

# Adds a tree structure to a model. This is very similar to @acts_as_nested_set@
# but uses the PostgreSQL-specific @ltree@ feature for schema storage.
#
# Your model must have a @path@ field of type @ltree@. This field will be a
# period-delimited list of IDs of records above this one in the hierarchy. In
# addition, you should also consider the following indexes:
#
# <pre><code>
# CREATE INDEX index1 ON table USING gist(path)
# CREATE INDEX index2 ON table USING btree(path)
# </code></pre>
#
# replacing @table@ with your table and @index1@/@index2@ with appropriate names
# for these indexes.
#
# @example
#   class MyModel < ActiveRecord::Base
#     include Hierarchy
#   end

module Hierarchy
  extend ActiveSupport::Concern
  
  # @private
  included do |base|
    base.extend ActiveSupport::Memoizable
    base.memoize :index_path, :ancestors
    
    base.scope :parent_of, ->(obj) { obj.top_level? ? base.where('false') : base.where(id: obj.index_path.last) }
    base.scope :children_of, ->(obj) { base.where(path: obj.my_path) }
    base.scope :ancestors_of, ->(obj) { obj.top_level? ? base.where('false') : base.where(id: obj.index_path.to_a) }
    base.scope :descendants_of, ->(obj) { base.where([ "path <@ ?", obj.my_path ]) }
    base.scope :siblings_of, ->(obj) { base.where(path: obj.path) }
    base.scope :priority_order, base.order("NLEVEL(path) ASC")
    base.scope :top_level, base.where([ "path IS NULL or path = ?", '' ])
    
    base.before_save { |obj| obj.path ||= '' }
  end

  module ClassMethods

    # @overload treeified
    #   @return [Hash<ActiveRecord::Base, Hash<...>>] All models organized
    #     into a tree structure. Returns a hash where each key is a tree root,
    #     and the values are themselves hashes whose keys are the children of the
    #     respective model.

    def treeified(root=nil, objects=nil)
      path = root ? root.content.my_path : ''
      root ||= Node.new(nil)
      objects ||= order('id ASC').all.sort_by { |o| [ o.index_path, o.id ] }

      while objects.first and objects.first.path == path
        child = objects.shift
        root << Node.new(child)
      end

      root.children.each do |child|
        treeified child, objects
      end

      return root
    end
  end

  # Methods added to instances of the class this module is included into.

  module InstanceMethods
    # Sets the object above this one in the hierarchy.
    #
    # @param [ActiveRecord::Base] parent The parent object.
    # @raise [ArgumentError] If @parent@ is an unsaved record with no primary key.

    def parent=(parent)
      raise ArgumentError, "Parent cannot be a new record" if parent.try(:new_record?)
      self.path = parent.try(:my_path)
    end

    # Returns an array of ancestors above this object. Note that a) this array
    # is ordered with the most senior ancestor at the beginning of the list, and
    # b) this is an _array_, not a _relation_. For that reason, you can pass
    # any additional scope options to the method.
    #
    # @param [Hash] options Additional finder options.
    # @return [Array] The objects above this one in the hierarchy.

    def ancestors(options={})
      return [] if top_level?
      objects = self.class.ancestors_of(self).scoped(options).group_by(&:id)
      index_path.map { |id| objects[id].first }
    end

    # @return [ActiveRecord::Relation] The objects below this one in the
    #   hierarchy.

    def descendants
      self.class.descendants_of self
    end

    # @return [ActiveRecord::Base] The object directly above this one in the
    #   hierarchy.

    def parent
      top_level? ? nil : self.class.parent_of(self).first
    end

    # @return [ActiveRecord::Relation] The objects directly below this one
    #   in the hierarchy.

    def children
      self.class.children_of self
    end

    # @return [Array] The objects at the same hierarchical level of this one.

    def siblings
      self.class.siblings_of(self) - [ self ]
    end

    # @return [true, false] Whether or not this object has no parents.

    def top_level?
      path.blank?
    end

    # @return [true, false] Whether or not this object has no children. Makes a
    #   database call.

    def bottom_level?
      children.empty?
    end

    # @private
    def my_path
      path.blank? ? id.to_s : "#{path}.#{id}"
    end

    # @private
    def index_path
      IndexPath.from_ltree path.to_s
    end
  end
end
