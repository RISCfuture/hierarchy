require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Hierarchy::IndexPath do
  describe ".<=>" do
    def compare(ip1, ip2)
      Hierarchy::IndexPath.new(*ip1) <=> Hierarchy::IndexPath.new(*ip2)
    end

    it "should return -1 if this index path comes before the given index path" do
      # all except last digit equal
      compare([ 1,2,3 ], [ 1,2,4 ]).should eql(-1)
      # unequal in higher precedence
      compare([ 1,2,3 ], [ 1,3,2 ]).should eql(-1)
      # other is longer
      compare([ 1,2,3 ], [ 1,2,3,4 ]).should eql(-1)
    end

    it "should return 1 if this index path comes after the given index path" do
      # all except last digit equal
      compare([ 1,2,4 ], [ 1,2,3 ]).should eql(1)
      # unequal in higher precedence
      compare([ 1,3,2 ], [ 1,2,3 ]).should eql(1)
      # this is longer
      compare([ 1,2,3,4 ], [ 1,2,3, ]).should eql(1)
    end

    it "should return 0 if the index paths are equal" do
      compare([ 1,2,3 ], [ 1,2,3 ]).should eql(0)
    end
  end
end
