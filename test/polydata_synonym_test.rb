require 'test/unit' 

class PolydataSynonymTest < ActiveSupport::TestCase
  def test_truth
    flunk # ActiveRecord not available?
    ps = PolydataSynonym.create!(:synonym => '=mike' )
    assert(ps.valid?)
    assert(ps.polydata_authority.is_a?(PolydataAuthority))
    
  end
end # /class PolyDataTest
