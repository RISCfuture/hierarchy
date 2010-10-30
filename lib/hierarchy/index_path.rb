module Hierarchy
  
  # An array of integers representing an ordered list of IDs. Duck-types an
  # @Array@ in many ways.

  class IndexPath
    include Enumerable

    delegate :&, :+, :-, :<<, :==, :[], :[]=, :at, :clear, :collect, :collect!,
             :concat, :count, :delete_at, :delete_if, :drop, :drop_while, :each,
             :each_index, :empty?, :eql?, :fetch, :index, :first, :include?,
             :insert, :join, :keep_if, :last, :length, :map, :map!, :pop, :push,
             :reject, :reject!, :reverse, :reverse!, :rindex, :select, :select!,
             :shift, :size, :slice, :slice!, :take, :take_while, :to_a, :to_ary,
             :unshift, :values_at, :|, to: :indexes

    # @overload initialize(id, ...)
    #   Creates an index path from a list of integer IDs.
    #   @param [Fixnum] id An integer ID.
    # @return [IndexPath] A new instance.
    # @raise [ArgumentError] If an invalid ID is given.

    def initialize(*indexes)
      raise ArgumentError, "IndexPath indexes must be integers" unless indexes.all? { |index| index.kind_of?(Fixnum) }
      @indexes = indexes
    end

    # Creates an index path from a PostgreSQL @LTREE@ column.
    #
    # @param [String] string An @LTREE@ column value, such as "1.10.22".
    # @return [IndexPath] A corresponding index path.

    def self.from_ltree(string)
      new(*(string.split('.').map(&:to_i)))
    end

    # Defines a natural ordering of index paths. Paths with lower IDs at the same
    # index level will come before those with higher IDs at that index level.
    # Lower IDs at shallower index levels come before lower IDs at deeper index
    # levels.
    #
    # @param [IndexPath] other An index path to compare.
    # @return [-1, 0, 1] -1 if this index path comes before the other one, 0 if
    #   they are identical, or 1 if this index path comes after the other one.
    # @raise [ArgumentError] If something other than an index path is given.

    def <=>(other)
      raise ArgumentError, "Can't compare IndexPath and #{other.class.to_s}" unless other.kind_of?(IndexPath)
      indexes <=> other.send(:indexes)
    end

    # @private
    def inspect() "#<#{self.class.to_s} #{@indexes.inspect}>" end

    private

    def indexes() @indexes end
  end
end
