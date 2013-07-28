require "forwardablex"
require "structx/version"

# StructX is an extension of Ruby standard Struct. The diffences are that 1) the
# constructor handles hash table as key-value pairs, 2) you can specify members
# as statements, and 3) you can set default values of member. StructX's API is
# compatible with Struct.
#
# @example Constructor with hash table
#   StructX.new(:x, :y, :z).new(x: 1, y: 2, z: 3) #=> #<struct x=1, y=10, z=100>
# @example Member sentences
#   class A < StructX
#     member :x
#     member :y
#     member :z
#   end
#   A.new(1, 2, 3) #=> #<struct A x=1, y=2, z=3>
# @example Default values
#   class B < StructX
#     member :x
#     member :y, default: 10
#     member :z, default: 100
#   end
#   B.new(1) # => #<struct B x=1, y=10, z=100>
class StructX
  include Enumerable

  class << self
    alias :orig_new :new
    private :orig_new

    # Same as Struct[].
    alias :[] :new

    # Create a instance or sublcass. If this class has members, create an
    # instance. The case handles hash table as key-value pairs. If this class
    # has no members, create a subclass.
    #
    # @param args [Array or Hash]
    #   Same as Struct if args is Array. Consider args as key-value pairs if it is Hash.
    def new(*args)
      # create an instance
      return orig_new(*args) if @member

      # create subclass
      Class.new(StructX).tap do |subclass|
        # class name
        if args.first.kind_of?(String)
          const_set(args.first, subclass)
          args = args.drop(1)
        end

        # set members
        args.each {|m| subclass.member(*m)}

        # this is according to MRI, why yield?
        yield if block_given?
      end
    end

    # Same as Struct#members.
    def members
      (@member ||= {}).keys
    end

    # Add member into structure.
    #
    # @param name [Symbol]
    #   member name
    # @param data [Hash]
    #   member options
    def member(name, data={})
      (@member ||= {})[name] = Hash.new.merge(data)

      # define member's value reader
      define_method(name) do
        @value[name]
      end

      # define member's value writer
      define_method("%s=" % name) do |val|
        @value[name] = val
      end
    end

    # Return default values.
    #
    # @return [Hash{Symbol=>Object}]
    #   default values
    def default_values
      @member.inject({}) do |tbl, (key, val)|
        tbl.tap {|x| x[key] = val[:default] if val.has_key?(:default)}
      end
    end

    def immutable(b=true)
      @immutable = b
    end

    def immutable?
      @immutable
    end

    private

    def inherited(subclass)
      @member.each {|key, data| subclass.member(key, data)} if @member
      subclass.instance_variable_set(:@immutable, true) if @immutable
    end
  end

  # almost methods are forwarded to value table
  forward! :class, :members, :immutable?
  forward :@value, :each, :each_pair
  forward! :@value, :values, :length, :size, :hash
  forward! lambda{|x| @value.values}, :each, :values_at

  alias :to_a :values

  # See Struct.new.
  def initialize(*values)
    if values.first.kind_of?(Hash) and values.size == 1
      @value = __build__(values.first)
    else
      raise ArgumentError.new("struct size differs #{values}  #{members} ") if values.size > members.size
      @value = __build__(members.zip(values))
    end
  end

  # Same as Struct#[].
  def [](idx)
    case idx
    when Integer
      size > idx && -size <= idx ? values[idx] : (raise IndexError.new(idx))
    when Symbol, String
      members.include?(idx.to_sym) ? @value[idx.to_sym] : (raise NameError.new(idx.to_s))
    end
  end

  # Same as Struct#[].
  alias :get :"[]"

  # Same as Struct#[]=.
  def []=(idx, val)
    case idx
    when Integer
      if size > idx && -size <= idx
        if not(immutable?)
          @value[members[idx]] = val
        else
          self.class.new(@value.merge(members[idx] => val))
        end
      else
        raise IndexError.new(idx)
      end
    when Symbol, String
      if members.include?(idx.to_sym)
        if not(immutable?)
          @value[idx.to_sym] = val
        else
          self.class.new(@value.merge(idx.to_sym => val))
        end
      else
        raise NameError.new(idx.to_s)
      end
    end
  end

  # Same as #[]=, but you can set values by hash.
  def set(pairs={})
    if not(immutable?)
      pairs.each {|idx, val| obj[idx] = val}
    else
      pairs.inject(self) {|obj, (idx, val)| obj.send("[]=", idx, val)}
    end
  end

  # Same as Struct#inspect.
  def inspect
    name = self.class.inspect[0] == "#" ? "" : " " + self.class.inspect
    values = @value.map do |key, val|
      k = (key.to_s[0] == "@" ? ":" : "") + key.to_s
      v = self == val ? "#<struct %s:...>" % val : val.inspect
      "%s=%s" % [k, v]
    end
    "#<struct%s %s>" % [name, values.join(", ")]
  end

  # Same as Struct#eql?.
  def eql?(other)
    self.class == other.class and @value == other.to_h
  end
  alias :"==" :eql?

  # Same as Struct#to_h. This method is available in Ruby 1.9 too.
  def to_h
    @value
  end

  private

  def __build__(data)
    tbl = data.inject({}) {|tbl, (m, val)| tbl.tap {|x| x[m] = val if val}}
    self.class.default_values.merge(tbl)
  end
end
