require 'test/unit' 
require "polydata/instance"


class InstanceTest < ActiveSupport::TestCase
  def test_truth
    instance = Polydata::Instance.new(4, 'mike', '+supporter')
    assert_equal(4, instance.id)
    assert_equal('mike', instance.value)
    assert_equal('+supporter', instance.query_path)
    assert_equal(instance.value, instance.render )
  end
end # /class InstanceTest
