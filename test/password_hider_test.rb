$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'interfaces'

include Interfaces

class PasswordHiderTest < Test::Unit::TestCase
  def test_hide
    p = PasswordHider.new("PW")
    assert_equal "barHIDDEN foo", p.hide("bar<PW>bla</PW> foo")
    assert_equal "barGEHEIM foo", p.hide("bar<PW>bla</PW> foo", "GEHEIM")
    assert_equal "barHIDDEN foo HIDDEN mist", p.hide("bar<PW>bla</PW> foo <PW>BUH</PW> mist")

    p = PasswordHider.new("PW", 'VERSTECKT')
    assert_equal "barVERSTECKT foo", p.hide("bar<PW>bla</PW> foo")
    assert_equal "barWEG foo", p.hide("bar<PW>bla</PW> foo", "WEG")
  end

  def test_mask
    p = PasswordHider.new("PW")
    assert_equal "<PW>bla</PW>", p.mask("bla")

  end

  def test_unmask
    p = PasswordHider.new("PW")
    assert_equal "foo bla  bar" , p.unmask("foo <PW>bla</PW>  bar")
  end

end
