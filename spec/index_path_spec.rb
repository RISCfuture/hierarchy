require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Hierarchy::IndexPath do
  describe ".<=>" do
    def compare(ip1, ip2)
      Hierarchy::IndexPath.new(*ip1) <=> Hierarchy::IndexPath.new(*ip2)
    end

    it "should return -1 if this index path comes before the given index path" do
      # all except last digit equal
      expect(compare([ 1,2,3 ], [ 1,2,4 ])).to eql(-1)
      # unequal in higher precedence
      expect(compare([ 1,2,3 ], [ 1,3,2 ])).to eql(-1)
      # other is longer
      expect(compare([ 1,2,3 ], [ 1,2,3,4 ])).to eql(-1)
    end

    it "should return 1 if this index path comes after the given index path" do
      # all except last digit equal
      expect(compare([ 1,2,4 ], [ 1,2,3 ])).to eql(1)
      # unequal in higher precedence
      expect(compare([ 1,3,2 ], [ 1,2,3 ])).to eql(1)
      # this is longer
      expect(compare([ 1,2,3,4 ], [ 1,2,3, ])).to eql(1)
    end

    it "should return 0 if the index paths are equal" do
      expect(compare([ 1,2,3 ], [ 1,2,3 ])).to eql(0)
    end
  end
end
