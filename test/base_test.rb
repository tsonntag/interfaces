$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'interfaces'

include Interfaces

class Foo < Base
  attribute :foo
end

class BaseTest < Test::Unit::TestCase

  def test_params
    b = Foo.new  foo: 'bar'
    assert_equal 'bar', b.foo
    assert_raise NoMethodError do
      b.bla
    end
  end

  def test_logger
    b = Foo.new
    assert_not_nil b.logger
  end

end
