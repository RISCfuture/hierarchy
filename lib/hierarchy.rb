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
  included do
    scope :parent_of, ->(obj) { obj.top_level? ? where('false') : where(id: obj.index_path.last) }
    scope :children_of, ->(obj) { where(path: obj.my_path) }
    scope :ancestors_of, ->(obj) { obj.top_level? ? where('false') : where(id: obj.index_path.to_a) }
    scope :descendants_of, ->(obj) { where("path <@ ?", obj.my_path) }
    scope :siblings_of, ->(obj) { where(path: obj.path) }
    scope :priority_order, order("NLEVEL(path) ASC")
    scope :top_level, where("path IS NULL or path = ?", '')

    before_save { |obj| obj.path ||= '' }
    before_save :update_children_with_new_parent
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
    @ancestors ||= begin
      return [] if top_level?
      objects = self.class.ancestors_of(self).scoped(options).group_by(&:id)
      index_path.map { |id| objects[id].first }
    end
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

  # @return top level parent or nil(if current obj is top level)
  def top_level
    self.top_level? ? nil : self.class.find(self.path.split('.').first)
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
    @index_path ||= IndexPath.from_ltree path.to_s
  end

  private

  # if our parent has changed, update our children's paths
  def update_children_with_new_parent
    if path_changed? and not new_record? then
      old_path = (path_was.blank? ? id.to_s : "#{path_was}.#{id}")
      self.class.where("path <@ ?", old_path).update_all([ "path = TEXT2LTREE(REPLACE(LTREE2TEXT(path), ?, ?))", old_path, my_path ])
    end
  end
end
