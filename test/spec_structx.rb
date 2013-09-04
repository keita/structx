require "structx"

class A < StructX
  member :x
  member :y, default: 10
  member :z, type: Integer, default: 100
end

class B < StructX
  member :p0, default: lambda { $N }
  member :p1, default: lambda {|obj| $N + 1}
  member :p2, default: lambda {|obj, data| $N +2}
end

describe "StructX" do
  describe "StructX.new(:x, :y, :z)" do
    before do
      @class = StructX.new(:x, :y, :z)
      @immutable = Class.new(@class).tap {|subclass| subclass.immutable}
    end

    it "should have 3 members" do
      @class.members.size.should == 3
    end

    it "should create from StructX subclass" do
      should.not.raise do
        Class.new(StructX).new(:x).new(1)
      end
    end

    it "should inherit members" do
      Class.new(@class).members.should == [:x, :y, :z]
    end

    it "should create an instance" do
      @class.new(1, 2, 3).tap do |obj|
        obj.x.should == 1
        obj.y.should == 2
        obj.z.should == 3
      end
      @class.new(true, false, nil).tap do |obj|
        obj.values.should == [true, false]
      end
    end

    it "should create an instance with key" do
      @class.new(x: 1, y: 2, z: 3).tap do |obj|
        obj.x.should == 1
        obj.y.should == 2
        obj.z.should == 3
      end
    end

    it "should get members" do
      @class.members.tap do |m|
        m.should.include(:x)
        m.should.include(:y)
        m.should.include(:z)
      end
    end

    it "should raise ArgumentError when number of values are greater than number of members" do
      should.raise(ArgumentError) do
        @class.new(1, 2, 3, 4)
      end
    end

    it "should create an instance with #[]" do
      @class[1, 2, 3].tap do |obj|
        obj.x.should == 1
        obj.y.should == 2
        obj.z.should == 3
      end
    end

    it "should equal" do
      @class.new(1, 2, 3).should == @class.new(1, 2, 3)
    end

    it "should write and get member's value" do
      @class.new(1, 2, 3).tap do |obj|
        obj.x = 2
        obj.y = 3
        obj.z = 4
        obj.x.should == 2
        obj.y.should == 3
        obj.z.should == 4
      end
    end

    it "should get member's value with index" do
      @class.new(1, 2, 3).tap do |x|
        x[0].should == 1
        x[1].should == 2
        x[2].should == 3
        should.raise(IndexError) { x[-4] }
        should.raise(IndexError) { x[3] }
        x[:x].should == 1
        x[:y].should == 2
        x[:z].should == 3
        should.raise(NameError) { x[:a] }
        # by #get
        x.get(:x).should == 1
        x.get(:y).should == 2
        x.get(:z).should == 3
      end
    end

    it "should set member's value with index" do
      @class.new(1, 2, 3).tap do |x|
        x[0] = 2
        x[1] = 3
        x[2] = 4
        x[0].should == 2
        x[1].should == 3
        x[2].should == 4
        should.raise(IndexError) { x[-4] = 1 }
        should.raise(IndexError) { x[3] = 1 }
        x[:x] = 3
        x[:y] = 4
        x[:z] = 5
        x[:x].should == 3
        x[:y].should == 4
        x[:z].should == 5
        should.raise(NameError) { x[:a] = 1}
      end
      # test for #set
      @class.new(1, 2, 3).tap do |x|
        x.set(x: 4, y: 5, z: 6)
        x.values.should == [4, 5, 6]
      end

      # immutable tests
      orig = @immutable.new(1, 2, 3)
      orig.should.kind_of StructX
      orig.values.should == [1, 2, 3]
      updated = orig.set(x: 4, y: 5, z: 6)
      updated.should.kind_of StructX
      updated.values.should == [4, 5, 6]
      orig.values.should == [1, 2, 3]
    end

    it "should iterate values" do
      vals = []
      @class.new(1, 2, 3).tap{|x| x.each {|val| vals << val}; vals.should == x.values}
    end

    it "should iterate pairs of key and value" do
      vals = []
      @class.new(1, 2, 3).tap{|x| x.each_pair {|k, v| vals << [k, v]}; vals.should == x.to_h.to_a}
    end

    it "should get size" do
      @class.new(1, 2, 3).size.should == 3
    end

    it "should get members as strings" do
      @class.new.members.should == [:x, :y, :z]
    end

    it "should select" do
      @class.new(1, 2, 3).select{|i| i.odd?}.should == [1, 3]
    end

    it "should get values" do
      @class.new(1, 2, 3).values.should == [1, 2, 3]
    end

    it "should get values at" do
      @class.new(1, 2, 3).values_at(0..1).should == [1, 2]
    end
  end

  StructX.new("TestName", :x, :y)

  describe 'StructX.new("TestName", :x, :y)' do
    it "should have 2 members" do
      StructX::TestName.members.size.should == 2
    end

    it "should create class" do
      should.not.raise {StructX::TestName}
    end

    it "should get values" do
      StructX::TestName.new(1, 2).tap do |obj|
        obj.x.should == 1
        obj.y.should == 2
      end
    end
  end

  describe "A < StructX" do
    it "should have 3 members" do
      A.members.size.should == 3
    end

    it "should get members" do
      A.new(x: 1, y: 2, z: 3).tap do |obj|
        obj.x.should == 1
        obj.y.should == 2
        obj.z.should == 3
      end
    end

    it "should get default value" do
      A.new(1).tap do |obj|
        obj.x.should == 1
        obj.y.should == 10
        obj.z.should == 100
      end
      A.new.tap do |obj|
        obj.x.should == nil
        obj.y.should == 10
        obj.z.should == 100
      end
    end
  end

  describe "B < StructX" do
    it "should get default value" do
      $N = 1
      obj1 = B.new
      $N = 10
      obj2 = B.new
      obj1.values.should == [1, 2, 3]
      obj2.values.should == [10, 11, 12]
    end
  end
end

