require "structx"
require "ruby-version"

def patch(code)
  ## Struct -> StructX
  code = code.gsub("Struct", "StructX")
  ## clear require_relative
  code = code.gsub(/^require_relative.*$/, "")
  ## modify error message for test_struct_subclass
  # StructX can handle security error but the message is different
  code = code.gsub("Insecure: can't modify \#\{st}::S", "Insecure: can't modify hash")
end

def load_test(target)
  require_relative "../test/ruby/#{target}/envutil"
  path = File.join(File.dirname(__FILE__), "ruby", target, "test_struct.rb")
  eval patch(File.read(path))
end

if Ruby::Engine::NAME == "ruby"
  if Ruby::Version >= "1.9" and Ruby::Version < "2.0"
    load_test("1.9")
  end

  if Ruby::Version >= "2.0"
    load_test("2.0")
  end
else
  puts "We cannot run compatibility test with jruby and rbx."
  puts "Related to Struct, these VMs are not compatible with MRI."
end

