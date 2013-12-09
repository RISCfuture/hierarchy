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
      expect(Model.parent_of(@objects[:parent_1_1])).to eq([ @objects[:grandparent_1] ])
      expect(Model.parent_of(@objects[:parent_2_2])).to eq([ @objects[:grandparent_2] ])
    end

    it "should return an empty relation for top-level objects" do
      expect(Model.parent_of(@objects[:grandparent_1])).to be_empty
      expect(Model.parent_of(@objects[:grandparent_2])).to be_empty
    end
  end

  describe ".children_of" do
    it "should return the direct children of an object" do
      expect(Model.children_of(@objects[:grandparent_1])).to eq([ :parent_1_1, :parent_1_2 ].map { |name| @objects[name] })
      expect(Model.children_of(@objects[:parent_2_1])).to eq([ :child_2_1_1, :child_2_1_2 ].map { |name| @objects[name] })
    end

    it "should return an empty relation for leaf objects" do
      expect(Model.children_of(@objects[:child_1_1_1])).to be_empty
      expect(Model.children_of(@objects[:child_2_2_2])).to be_empty
    end
  end

  describe ".ancestors_of" do
    it "should return all ancestors of an object" do
      expect(Model.ancestors_of(@objects[:child_1_2_1])).to eq([ :grandparent_1, :parent_1_2 ].map { |name| @objects[name] })
      expect(Model.ancestors_of(@objects[:parent_2_1])).to eq([ @objects[:grandparent_2] ])
    end

    it "should return an empty relation for top-level objects" do
      expect(Model.ancestors_of(@objects[:grandparent_1])).to be_empty
    end
  end

  describe ".descendants_of" do
    it "should return all descendants of an object" do
      expect(Model.descendants_of(@objects[:grandparent_2])).to eq([ :parent_2_1, :parent_2_2, :child_2_1_1, :child_2_1_2, :child_2_2_1, :child_2_2_2 ].map { |name| @objects[name] })
      expect(Model.descendants_of(@objects[:parent_2_1])).to eq([ :child_2_1_1, :child_2_1_2 ].map { |name| @objects[name] })
    end

    it "should return an empty relation for leaf objects" do
      expect(Model.children_of(@objects[:child_1_1_1])).to be_empty
      expect(Model.children_of(@objects[:child_2_2_2])).to be_empty
    end
  end

  describe ".siblings_of" do
    it "should return all sibling objects" do
      expect(Model.siblings_of(@objects[:parent_1_1])).to eq([ :parent_1_1, :parent_1_2 ].map { |name| @objects[name] })
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
      expect(object.path).to eql("#{path}.#{parent.id}")
    end

    it "should update children's paths as necessary" do
      child = Model.create!
      grandchild = Model.create!(parent: child)
      parent = Model.create!
      new_grandparent = Model.create!

      child.update_attribute :parent, parent
      expect(child.path).to eql(parent.id.to_s)
      parent.update_attribute :parent, new_grandparent
      expect(parent.path).to eql(new_grandparent.id.to_s)
      expect(child.reload.path).to eql([ new_grandparent.id, parent.id ].join('.'))
      expect(grandchild.reload.path).to eql([ new_grandparent.id, parent.id, child.id ].join('.'))
    end
  end

  describe "#top_level?" do
    it "should return true for a top-level object" do
      expect(Model.create!).to be_top_level
    end

    it "should return false for an object with a parent" do
      parent = Model.create!
      expect(Model.create!(parent: parent)).not_to be_top_level
    end
  end

  describe "#bottom_level?" do
    it "should return true for an object with no children" do
      expect(Model.create!).to be_bottom_level
    end
    it "should return false for an object with children" do
      parent = Model.create!
      Model.create!(parent: parent)
      expect(parent).not_to be_bottom_level
    end
  end
  
  describe "#ancestors" do
    it "should return an empty array for a top-level object" do
      expect(Model.create!.ancestors).to eql([])
    end
  end
end
