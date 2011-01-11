# 
# > cd vendor/plugins/polydata/lib 
# > ruby ../test/request_test.rb 

require 'test/unit' 
require 'cgi'
require 'rubygems'
require 'mocha'
require 'activerecord'
#require '../../at_linksafe/lib/at_linksafe.rb'
require "polydata.rb"

class RequestTest < ActiveSupport::TestCase
  def OFFtest_truth
    hsh = { 
      :action => '$get',
      :authority => '@llli*sys*reg',
      :requester => '@llli*sys*data',
      :type => "+supporter/kintera_id$value=185253295",
    }
    polydata_request = Polydata::Request.new(hsh)
    assert_equal('@llli*sys*reg/(+supporter/kintera_id$value=185253295)/($get)/(@llli*sys*data)', polydata_request.encode)
    assert(polydata_request.type.child.data_type == '$value')
    assert(polydata_request.type.child.value == '185253295')
    assert(polydata_request.type.child.relation == '=')
    assert(polydata_request.type.child.flat_query_path == '+supporter/kintera_id')

    uri = Polydata.end_point_uri( 
      :polydata_request => polydata_request, 
      :end_point => 'https://reg.llli.org/xri/'
      )
    assert_equal(uri, 'https://reg.llli.org/xri/%40llli%2Asys%2Areg%2F%28%2Bsupporter%2Fkintera_id%24value%3D185253295%29%2F%28%24get%29%2F%28%40llli%2Asys%2Adata%29')
  end
  
  def test_decode
    hsh = { 
      :authority => '@llli*sys',
#      :action => '$get',
      :type => "+supporter$value=@!1234.asdf",
    }
    polydata_request = Polydata::Request.new(hsh)    
    polydata_request = Polydata::Request.decode(polydata_request.encode)
    assert(polydata_request.type.has_data?)
    assert_equal( '+supporter', polydata_request.type.flat_query_path)
    
    polydata_request = Polydata::Request.decode('@llli*sys/(+supporter$value=@!asdf.1234)')
    assert(polydata_request.type.has_data?)
    assert_equal( '+supporter', polydata_request.type.flat_query_path)
    
    polydata_request = Polydata::Request.decode('@llli*sys/(+supporter$value=@!asdf.1234/role$value=ActiveMember)')
    assert(polydata_request.type.has_data?)
    assert_equal( '+supporter/role', polydata_request.type.flat_query_path)
    assert(polydata_request.type.child.has_data?, polydata_request.type.child.inspect)
    assert_equal( '+supporter', polydata_request.type.flat_query_path(0))
    assert_equal( '+supporter/role', polydata_request.type.flat_query_path(1))
    assert_equal( 'ActiveMember', polydata_request.type.child.value)


    polydata_request = Polydata::Request.decode('@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(+address$id=1661373)')
    assert_equal( '+address', polydata_request.type.flat_query_path)
    assert(!polydata_request.type[0].is_canonical?)
    assert(!polydata_request.type.last.is_canonical?)
    assert_equal('+address', polydata_request.type[0].query_path)
    assert_equal('1661373', polydata_request.type[0].instance_id)
    assert_equal('+address', polydata_request.type.last.query_path)
    assert_equal('1661373', polydata_request.type.last.instance_id)

    polydata_request = Polydata::Request.decode('@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(1661373)')
    assert(polydata_request.type[0].is_canonical?)
    assert_equal('1661373', polydata_request.type[0].query_path)
    assert_equal('1661373', polydata_request.type[0].instance_id)
    assert(polydata_request.type.last.is_canonical?)
    assert_equal('1661373', polydata_request.type.last.query_path)
    assert_equal('1661373', polydata_request.type.last.instance_id)
    
  end
  
  def OFFtest_request
    hsh = { 
      :action => '$get',
      :authority => '@llli*sys',
      :type => "+supporter/kintera_id$value=185253295",
    }
    polydata_request = Polydata::Request.new(hsh)
    assert(polydata_request.requester.nil?)
    assert_equal('@llli*sys', polydata_request.authority)
    assert_equal('+supporter/kintera_id', polydata_request.type.child.flat_query_path, polydata_request.type.inspect)
    assert_equal('=', polydata_request.type.child.relation)
    assert_equal('$value', polydata_request.type.child.data_type)
    assert_equal('185253295', polydata_request.type.child.value)
    
    polydata_request.type = {:query_path => '+supporter', :data_type => '$value', :relation => '=', :value => '@!72CD'}
    assert(polydata_request.type.has_data?)
    assert_equal('+supporter', polydata_request.type.flat_query_path)
    assert_equal('$value', polydata_request.type.data_type)
    assert_equal('=', polydata_request.type.relation)
    assert_equal('@!72CD', polydata_request.type.value)
    assert_nil( polydata_request.type.instance_id)
    
    polydata_request.type = {:query_path => '+supporter', :data_type => '$id', :relation => '=', :value => '1234'}
    assert_equal('+supporter', polydata_request.type.flat_query_path)
    assert_equal('$id', polydata_request.type.data_type)
    assert_equal('=', polydata_request.type.relation)
    assert_equal('1234', polydata_request.type.value)
    assert_equal('1234', polydata_request.type.instance_id)

    hsh = { 
      :action => '$get',
      :authority => '@llli*sys',
      :requester => '',
      :type => "+supporter/kintera_id$value=185253295",
    }
    polydata_request = Polydata::Request.new(hsh)
    assert(polydata_request.requester.nil?)
    assert(polydata_request.requester_cid.nil?)
  end

  def OFFtest_cid
    authority_cid = '@!1234!5678'
    Polydata.stubs(:resolve_cid).with('@llli*sys').once.returns(authority_cid)

    hsh = { 
      :action => '$get',
      :authority => '@llli*sys',
      :requester => '@llli*sys*data',
      :type => "+supporter/kintera_id$value=185253295",
    }
    polydata_request = Polydata::Request.new(hsh)
    assert_equal(authority_cid, polydata_request.authority_cid)
    assert_equal(authority_cid, polydata_request.authority_cid) # testing second call is @authority_cid ||= cached
  end

end
