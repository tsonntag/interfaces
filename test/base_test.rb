$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'interfaces'

include Interfaces

class BaseTest < Test::Unit::TestCase
  def test_name
    b = Base.new('foo', {})
    assert_equal 'foo', b.name
  end

  def test_params
    b = Base.new('foo', {:foo => 'bar'})
    assert_equal 'bar', b[:foo]
    assert_equal 'bar', b.foo
    assert_raise NoMethodError do
      b.bla
    end
  end

  def test_logger
    b = Base.new( 'foo', {})
    assert_not_nil b.logger
  end

end
