require 'spec_helper'

describe Hierarchy do
  before :each do
    @objects = Hash.new
    2.times { |i| @objects[:"grandparent_#{i + 1}"] = Model.create! }
    2.times do |gp_num|
      2.times { |i| @objects[:"parent_#{gp_num + 1}_#{i + 1}"] = Model.create!(parent: @objects[:"grandparent_#{gp_num + 1}"]) }
    end
    2.times do |gp_num|
      2.times do |p_num|
        2.times { |i| @objects[:"child_#{gp_num + 1}_#{p_num + 1}_#{i + 1}"] = Model.create!(parent: @objects[:"parent_#{gp_num + 1}_#{p_num + 1}"]) }
      end
    end
  end

  describe ".parent_of" do
    it "should return the parent object" do
      Model.parent_of(@objects[:parent_1_1]).should == [ @objects[:grandparent_1] ]
      Model.parent_of(@objects[:parent_2_2]).should == [ @objects[:grandparent_2] ]
    end

    it "should return an empty relation for top-level objects" do
      Model.parent_of(@objects[:grandparent_1]).should be_empty
      Model.parent_of(@objects[:grandparent_2]).should be_empty
    end
  end

  describe ".children_of" do
    it "should return the direct children of an object" do
      Model.children_of(@objects[:grandparent_1]).should == [ :parent_1_1, :parent_1_2 ].map { |name| @objects[name] }
      Model.children_of(@objects[:parent_2_1]).should == [ :child_2_1_1, :child_2_1_2 ].map { |name| @objects[name] }
    end

    it "should return an empty relation for leaf objects" do
      Model.children_of(@objects[:child_1_1_1]).should be_empty
      Model.children_of(@objects[:child_2_2_2]).should be_empty
    end
  end

  describe ".ancestors_of" do
    it "should return all ancestors of an object" do
      Model.ancestors_of(@objects[:child_1_2_1]).should == [ :grandparent_1, :parent_1_2 ].map { |name| @objects[name] }
      Model.ancestors_of(@objects[:parent_2_1]).should == [ @objects[:grandparent_2] ]
    end

    it "should return an empty relation for top-level objects" do
      Model.ancestors_of(@objects[:grandparent_1]).should be_empty
    end
  end

  describe ".descendants_of" do
    it "should return all descendants of an object" do
      Model.descendants_of(@objects[:grandparent_2]).should == [ :parent_2_1, :parent_2_2, :child_2_1_1, :child_2_1_2, :child_2_2_1, :child_2_2_2 ].map { |name| @objects[name] }
      Model.descendants_of(@objects[:parent_2_1]).should == [ :child_2_1_1, :child_2_1_2 ].map { |name| @objects[name] }
    end

    it "should return an empty relation for leaf objects" do
      Model.children_of(@objects[:child_1_1_1]).should be_empty
      Model.children_of(@objects[:child_2_2_2]).should be_empty
    end
  end

  describe ".siblings_of" do
    it "should return all sibling objects" do
      Model.siblings_of(@objects[:parent_1_1]).should == [ :parent_1_1, :parent_1_2 ].map { |name| @objects[name] }
    end
  end

  describe "#parent=" do
    it "should raise an error if parent is unsaved" do
      expect { Model.create!.parent = Model.new }.to raise_error(ArgumentError)
    end

    it "should set the path ltree appropriately" do
      ggp = Model.create!
      gp = Model.create!(path: ggp.id.to_s)
      pa = Model.create!(path: "#{ggp.id}.#{gp.id}")
      path = [ ggp.id, gp.id, pa.id ].join('.')

      object = Model.new
      parent = Model.create!(path: path)
      object.parent = parent
      object.save!
      object.path.should eql("#{path}.#{parent.id}")
    end
  end

  describe "#top_level?" do
    it "should return true for a top-level object" do
      Model.create!.should be_top_level
    end

    it "should return false for an object with a parent" do
      parent = Model.create!
      Model.create!(parent: parent).should_not be_top_level
    end
  end

  describe "#bottom_level?" do
    it "should return true for an object with no children" do
      Model.create!.should be_bottom_level
    end
    it "should return false for an object with children" do
      parent = Model.create!
      Model.create!(parent: parent)
      parent.should_not be_bottom_level
    end
  end
  
  describe "#ancestors" do
    it "should return an empty array for a top-level object" do
      Model.create!.ancestors.should eql([])
    end
  end
end
