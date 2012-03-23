#
# > vendor/plugins/polydata/lib mmell$ ruby ../test/type_data_test.rb

require 'test/unit'
require "polydata/type_data.rb"
require "polydata/type_segment.rb"

class TypeDataTest < Test::Unit::TestCase

  def test_one_level
    assert_raise(RuntimeError) { Polydata::TypeData.new }
    assert_raise(RuntimeError) { Polydata::TypeData.new('') }
    assert_raise(RuntimeError) { Polydata::TypeData.new({}) }

    td = Polydata::TypeData.new({:query_path => '+supporter', :data_type => '$value', :relation => '=', :value => '@!72CD'})
    assert_equal('+supporter$value=@!72CD', td.encode)
    assert_equal('+supporter$value=@!72CD', td.encode(0))
    assert(td.has_data?)
    assert_equal('+supporter', td.flat_query_path)
    assert_equal('$value', td[0].data_type)
    assert_equal('=', td[0].relation)
    assert_equal('@!72CD', td[0].value)
    assert_nil( td[0].instance_id)
    td[0].instance_id = 2
    assert_equal( 2, td[0].instance_id)
    td[0].instance_id = [2,3]
    assert_equal( [2,3], td[0].instance_id)


    td = Polydata::TypeData.new('+supporter/')
    assert_equal('+supporter', td.encode)
    assert_equal('+supporter', td.encode(0))
    assert_equal("+supporter", td.flat_query_path)
    assert_nil(td.child_of)

    td = Polydata::TypeData.new("+supporter/role/#{Polydata::TypeSegment::ParentQueryPath}")
    assert_equal('+supporter/role/_', td.encode)
    assert_equal('+supporter', td.encode(0))
    assert_equal('+supporter/role', td.encode(1))
    assert_equal('+supporter/role/_', td.encode(2))
    assert_equal("+supporter", td.flat_query_path(2))

    td = Polydata::TypeData.new('+supporter$value=$null')
    assert_equal('+supporter$value=$null', td.encode)
    assert_equal('+supporter$value=$null', td.encode(0))
    assert(td[0].has_data?)
    assert_equal(nil, td[0].value)

    td = Polydata::TypeData.new('+supporter$value=@!72CD')
    assert(td.has_data?)
    assert_equal('$value', td[0].data_type)

    td = Polydata::TypeData.new('+supporter$value=@!72CD/')
    assert(td.has_data?)
    assert_equal('$value', td[0].data_type)

    td = Polydata::TypeData.new('+supporter$value=@!72CD')
    assert(td[0].has_data?)
    assert_equal('$value', td[0].data_type)
    assert_equal('=', td[0].relation)
    assert_equal('@!72CD', td[0].value)
    assert_nil( td[0].instance_id)

    td = Polydata::TypeData.new('+supporter$id>1234')
    assert(td[0].has_data?)
    assert_equal('$id', td[0].data_type)
    assert_equal('>', td[0].relation)
    assert_equal('1234', td[0].value)

    td = Polydata::TypeData.new('+supporter$modified>1234')
    assert_equal('$modified', td[0].data_type)

    td = Polydata::TypeData.new('+supporter$nada>1234')
    assert_nil(td[0].data_type)
  end

  def test_children
    td = Polydata::TypeData.new('+supporter$value=@!72CD.1/role')
    assert_equal('+supporter$value=@!72CD.1/role', td.encode)
    assert_equal('+supporter$value=@!72CD.1', td.encode(0))
    assert_equal('+supporter$value=@!72CD.1/role', td.encode(1))
    assert(td.has_data?)
    assert_equal('+supporter', td.flat_query_path( td.first ) )
    assert_equal('$value', td.first.data_type)
    assert_equal('=', td.first.relation)
    assert_equal('@!72CD.1', td.first.value)
    assert(td.child_of, td.inspect)
    assert_not_nil( td.child_of(td[0]) )
    assert_nil( td.child_of(td[1]) )
    assert_equal('+supporter/role', td.flat_query_path( td[1] ) )
    assert_equal('+supporter/role', td.flat_query_path( td.child_of(td[0]) ) )
    assert_equal('+supporter/role', td.flat_query_path( td.last ) )
    assert(!td.child_of.has_data?)
    assert_equal(td.child_of, td.last)

    td.delete_at(td.last.position)
    assert_nil(td.child_of)
    assert_equal('+supporter', td.flat_query_path(td.last))

    td = Polydata::TypeData.new('+admin/lllids$value=@llli*area*alaska/_/admins')
    assert_equal('+admin/lllids$value=@llli*area*alaska/_/admins', td.encode)
    assert_equal('+admin', td.encode(0))
    assert_equal('+admin/lllids$value=@llli*area*alaska', td.encode(1))
    assert_equal('+admin/lllids$value=@llli*area*alaska/_', td.encode(2))
    assert_equal('+admin/lllids$value=@llli*area*alaska/_/admins', td.encode(3))
    assert_equal('+admin', td.flat_query_path(0))
    assert_equal('+admin/admins', td.flat_query_path( td.last ))
    assert_equal('+admin/lllids', td.flat_query_path( td.child_of ))
    assert(td.child_of)

    td = Polydata::TypeData.new('+supporter$value=@!72CD/role$value=ActiveMember')
    assert_equal('+supporter$value=@!72CD/role$value=ActiveMember', td.encode)
    assert_equal('+supporter$value=@!72CD', td.encode(0))
    assert_equal('+supporter$value=@!72CD/role$value=ActiveMember', td.encode(1))
    assert(td.has_data?)
    assert(td.has_data?)
    assert_equal('+supporter', td.flat_query_path(0))
    assert_equal('$value', td[0].data_type)
    assert_equal('=', td[0].relation)
    assert_equal('@!72CD', td[0].value)

    assert(td.child_of)
    assert(td.child_of.has_data?)
    assert_equal('+supporter/role', td.flat_query_path(1))
    assert_equal('$value', td.child_of.data_type)
    assert_equal('=', td.child_of.relation)
    assert_equal('ActiveMember', td.child_of.value)

    td = Polydata::TypeData.new('+supporter$value=@!72CD/role$value=ActiveMember/foo$value=2')
    assert_equal('+supporter$value=@!72CD/role$value=ActiveMember/foo$value=2', td.encode)
    assert(td.has_data?)
    assert(td.child_of.has_data?)
    assert(td[2].has_data?)
    assert_equal('+supporter/role/foo', td.flat_query_path(2))
    assert_equal('$value', td[2].data_type)
    assert_equal('=', td[2].relation)
    assert_equal('2', td[2].value)
    assert_equal(td[2], td.last)

    td = Polydata::TypeData.new('+supporter$value=@!72CD/role$value=ActiveMember/foo$id=2')
    assert(td[0].has_data?, td.inspect)
    assert(td.child_of.has_data?)
    assert(td[2].has_data?)
    assert(td[2].instance_id)
    assert_equal('+supporter/role/foo', td.flat_query_path(2))
    assert_equal('$id', td[2].data_type)
    assert_equal('=', td[2].relation)
    assert_equal('2', td[2].value)

    td = Polydata::TypeData.new('+supporter/role$value=3/foo')
    assert(td.child_of.has_data?, td.inspect)
    assert(!td.last.has_data?, td.inspect)
    assert(td.child, td.inspect)
    assert_equal('+supporter/role/foo', td.flat_query_path(2))
    assert_equal('+supporter/role/foo', td.flat_query_path(td.last))
    assert_equal('$value', td.child_of.data_type)
    assert_equal('=', td.child_of.relation)
    assert_equal('3', td.child_of.value)

    td = Polydata::TypeData.new('+supporter/role/foo$value=2')
    assert(td.last.has_data?, td.inspect)
    assert(td[3].nil?)
    assert_equal('+supporter/role/foo', td.flat_query_path)
    assert_equal('+supporter', td.flat_query_path(0))
    assert_equal('+supporter/role', td.flat_query_path(1))
    assert_equal('+supporter/role/foo', td.flat_query_path(2))
    assert_equal('$value', td[2].data_type)
    assert_equal('=', td[2].relation)
    assert_equal('2', td[2].value)

    td = Polydata::TypeData.new('+supporter$value=@!72CD/role$value$in[ActiveMember,ActiveLeader]')
    assert_equal('+supporter$value=@!72CD/role$value$in[ActiveMember,ActiveLeader]', td.encode)
    assert(td.child_of.has_data?)
    assert_equal('+supporter/role', td.flat_query_path(1))
    assert_equal('$value', td.child_of.data_type)
    assert_equal('$in', td.child_of.relation)
    assert_equal('[ActiveMember,ActiveLeader]', td.child_of.value)

    td = Polydata::TypeData.new(
    [
      {
        :query_path => '+supporter',
        :data_type => '$value',
        :relation => '=',
        :value => '@!72CD.2'
      },
      {
        :query_path => 'role',
        :data_type => '$value',
        :relation => '$in',
        :value => '[ActiveMember,ActiveLeader]',
      }
    ]
    )
    assert_not_nil(td.child_of)
    assert(td.child_of.has_data?)
    assert_equal('+supporter/role', td.flat_query_path(1))
    assert_equal('$value', td.child_of.data_type)
    assert_equal('$in', td.child_of.relation)
    assert_equal('[ActiveMember,ActiveLeader]', td.child_of.value)

    td = Polydata::TypeData.new(
    [
      {
        :query_path => '+supporter',
        :data_type => '$value',
        :relation => '=',
        :value => '@!72CD'
        },
      'role$value$in[ActiveMember,ActiveLeader]'
      ]
      )
    assert(td.child_of.has_data?)
    assert_equal('+supporter/role', td.flat_query_path(1))
    assert_equal('$value', td.child_of.data_type)
    assert_equal('$in', td.child_of.relation)
    assert_equal('[ActiveMember,ActiveLeader]', td.child_of.value)
  end

  def test_parent_flat_query_path
    td = Polydata::TypeData.new(
    "+supporter/lllid$value=@llli*mike/#{Polydata::TypeSegment::ParentQueryPath}/lllid"
    )
    assert_equal('+supporter/lllid', td.flat_query_path)
    assert_equal('+supporter/lllid', td.flat_query_path(1))
    assert_equal('+supporter', td.flat_query_path(2))
    assert_equal('+supporter/lllid', td.flat_query_path(3))
    assert_equal('+supporter/lllid', td.flat_query_path(td.last))

    td = Polydata::TypeData.new(
    "+supporter/role$value=Leder/#{Polydata::TypeSegment::ParentQueryPath}/lllid"
    )
    assert_equal('+supporter/lllid', td.flat_query_path)
    assert_equal('+supporter', td.flat_query_path(0))
    assert_equal('+supporter/role', td.flat_query_path(1))
    assert_equal('+supporter', td.flat_query_path(2))
    assert_equal('+supporter/lllid', td.flat_query_path(3))
    assert_equal('+supporter/lllid', td.flat_query_path(td.last))

    td = Polydata::TypeData.new(
    "+supporter$value=@!72CD/role$value$in[ActiveMember,ActiveLeader]/#{Polydata::TypeSegment::ParentQueryPath}"
    )
    assert(td[2].is_parent_query?)
    assert_equal(td.flat_query_path, td.flat_query_path(2))

    td = Polydata::TypeData.new([
      {
        :query_path => '+supporter',
      :data_type => '$value',
      :relation => '=',
      :value => '@!72CD'
      },
      "role$value$in[ActiveMember,ActiveLeader]/#{Polydata::TypeSegment::ParentQueryPath}"
      ]
      )
    assert(td[2].is_parent_query?)
    assert_equal(td.flat_query_path, td.flat_query_path(2))

    td = Polydata::TypeData.new(
    "+supporter$value=@!72CD/role$value$in[ActiveMember,ActiveLeader]/#{Polydata::TypeSegment::ParentQueryPath}/lllid"
    )
    assert(td[2].is_parent_query?, td[2].inspect)
    assert_equal('+supporter/lllid', td.flat_query_path )
    assert_equal('+supporter', td.flat_query_path(0) )
    assert_equal('+supporter/role', td.flat_query_path(1) )
    assert_equal('+supporter', td.flat_query_path(2) )
    assert_equal('+supporter/lllid', td.flat_query_path(3) )

    td = Polydata::TypeData.new(
    "+supporter/foo1/foo2/#{Polydata::TypeSegment::ParentQueryPath}/foo3"
    )
    assert_equal('+supporter/foo1/foo3', td.flat_query_path )
    assert_equal('+supporter', td.flat_query_path(0) )
    assert_equal('+supporter/foo1', td.flat_query_path(1) )
    assert_equal('+supporter/foo1/foo2', td.flat_query_path(2) )
    assert_equal('+supporter/foo1', td.flat_query_path(3) )
    assert_equal('+supporter/foo1/foo3', td.flat_query_path(4) )

    td = Polydata::TypeData.new(
    "+supporter/foo1/foo2/#{Polydata::TypeSegment::ParentQueryPath}/#{Polydata::TypeSegment::ParentQueryPath}/foo3"
    )
    assert_equal('+supporter/foo3', td.flat_query_path )
    assert_equal('+supporter', td.flat_query_path(0) )
    assert_equal('+supporter/foo1', td.flat_query_path(1) )
    assert_equal('+supporter/foo1/foo2', td.flat_query_path(2) )
    assert_equal('+supporter/foo1', td.flat_query_path(3) )
    assert_equal('+supporter', td.flat_query_path(4) )
    assert_equal('+supporter/foo3', td.flat_query_path(5) )

  end

  def test_merge_parent
    td = Polydata::TypeData.new(
      [
        { :query_path => '+supporter' },
        'role$value$in[ActiveMember,ActiveLeader]'
      ]
      )
    assert(td.child_of)
    assert(td.child_of.has_data?)
    assert_equal('+supporter/role', td.flat_query_path(1))
    assert_equal('$value', td.child_of.data_type)
    assert_equal('$in', td.child_of.relation)
    assert_equal('[ActiveMember,ActiveLeader]', td.child_of.value)


    td = Polydata::TypeData.new(
    [
      '+supporter',
    "role$value$in[ActiveMember,ActiveLeader]/#{Polydata::TypeSegment::ParentQueryPath}"
    ]
    )
    assert(!td[0].has_data?)
    assert(td.child_of.has_data?)
    assert_equal('+supporter/role', td.flat_query_path(1))
    assert_equal('$value', td.child_of.data_type)
    assert_equal('$in', td.child_of.relation)
    assert_equal('[ActiveMember,ActiveLeader]', td.child_of.value)
    assert_equal("+supporter", td.flat_query_path(2))
  end

  def test_array
    td = Polydata::TypeData.new( '+supporter$id$in[123456]' )
    assert_nil(td[0].instance_id)
    assert_equal('$id', td[0].data_type)
    assert_equal('$in', td[0].relation)
    assert_equal('[123456]', td[0].value)
    assert_equal('+supporter$id$in[123456]', td.to_s)
    td[0].instance_id = "12"
    assert_equal('12', td[0].value)
    assert_equal('+supporter$id=12', td.to_s)
  end

end # /class TypeDataTest
