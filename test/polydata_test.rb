require 'test/unit' 
require "polydata.rb"


class PolyDataTest < ActiveSupport::TestCase
  def test_truth
    flunk # I have removed the String module....
    s = String.new
    assert(!s.original_nil?)
    assert(!s.nil?)

    s = 'null'
    assert(!s.original_nil?)
    assert(!s.nil?)

    s = nil
    assert(s.original_nil?)
    assert(s.nil?)

    s = '$null'
    assert(!s.original_nil?)
    assert(s.nil?)

    
  end
end # /class PolyDataTest
