# StructX

StructX is an extension of Ruby standard Struct. The diffences are that 1) the constructor handles hash table as key-value pairs, 2) you can specify members as statements, and 3) you can set default values of member. StructX's API is compatible with Struct.

## Installation

    $ gem install structx

## Usage

### Constructor with hash table

```ruby
StructX.new(:x, :y, :z).new(x: 1, y: 2, z: 3) #=> #<struct x=1, y=10, z=100>
```

### Member sentences

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
