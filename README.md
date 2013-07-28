# StructX

StructX is an extension of Ruby standard Struct. The diffences are that 1) the constructor handles hash table as key-value pairs, 2) you can specify members as statements, and 3) you can set default values of member. StructX's API is compatible with Struct.

[![Gem Version](https://badge.fury.io/rb/structx.png)](http://badge.fury.io/rb/structx) [![Build Status](https://travis-ci.org/keita/structx.png?branch=master)](https://travis-ci.org/keita/structx) [![Coverage Status](https://coveralls.io/repos/keita/structx/badge.png?branch=master)](https://coveralls.io/r/keita/structx) [![Code Climate](https://codeclimate.com/github/keita/structx.png)](https://codeclimate.com/github/keita/structx)

## Installation

    $ gem install structx

## Usage

### Constructor with hash table

```ruby
StructX.new(:x, :y, :z).new(x: 1, y: 2, z: 3) #=> #<struct x=1, y=10, z=100>
```

### Member declarations

```ruby
class A < StructX
  member :x
  member :y
  member :z
end
A.new(1, 2, 3) #=> #<struct A x=1, y=2, z=3>
```

### Default values

```ruby
class B < StructX
  member :x
  member :y, default: 10
  member :z, default: 100
end
B.new(1) # => #<struct B x=1, y=10, z=100>
```

You can set dynamic default values with proc object.

```ruby
class B < StructX
  member :x, default: lambda {$N}
  member :y, default: lambda {|obj| $N+1}
  member :z, default: lambda {|obj, data| $N+2}
end
$N = 1
B.new # => #<struct B x=1, y=2, z=3>
$N = 10
B.new # => #<struct B x=10, y=11, z=12>
```

### Immutable mode

```ruby
class C < StructX
  immutable true
  member :x
  member :y
  member :z
end
orig = C.new(1, 2, 3) #=> #<struct C x=1, y=2, z=3>
updated = orig.set(x: 4, y: 5, z: 6) #=> #<struct C x=4, y=5, z=6>
orig.values    #=> [1, 2, 3]
updated.values #=> [4, 5, 6]
```

## Documentation

- [API Documentation](http://rubydoc.info/gems/structx)

## License

StructX is free software distributed under MIT license.
The following files are copied from ruby's test case, so you should keep its lisense.

- test/ruby/1.9/test_struct.rb
- test/ruby/1.9/envutil.rb
- test/ruby/2.0/test_struct.rb
- test/ruby/2.0/envutil.rb

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
