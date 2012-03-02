# 
# > cd vendor/plugins/polydata/lib 
# > ruby ../test/render_test.rb 

require 'test/unit' 
require "polydata/render.rb"
require "polydata/request.rb"
require "polydata/type_data.rb"
require "polydata/type_segment.rb"
require "polydata/instance.rb"

class RenderTest < ActiveSupport::TestCase

  def test_truth
    polydata_request = Polydata::Request.new(
      :authority => '@llli',
      :type => "+supporter",
      :action => '$get',
      :action_minor => 'hash'
      )
    
    days = Polydata::Instance.new(1, 'M', '+supporter/days')
    days << Polydata::Instance.new(1, '2:00 - 4:00', '+supporter/days/hours')
    instance = Polydata::Instance.new(1, '@!asdf', '+supporter/leader')
    instance << days 
    
    renderer = Polydata::Render.new( :polydata_request => polydata_request )
    renderer << instance 
    
    puts renderer.to_s
  end

end
