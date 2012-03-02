# 
# > cd vendor/plugins/polydata/lib 
# > ruby ../test/polydata_cache_test.rb 

require 'test/unit' 
require 'rubygems'
require 'mocha'

require "polydata/request.rb"
require "polydata/type_data.rb"
require "polydata/type_segment.rb"
require "polydata/models/polydata_cache.rb"
require "polydata/models/polydata_cached_canonical_id.rb"

class PolydataCacheTest < ActiveSupport::TestCase
  def test_xml_v2_caching
    request = Polydata::Request.decode('@llli*sys/(+supporter/lllid$value$in[@llli*mike,@llli*jw]/_)/($get/xml$v2)/(@llli*sys)')
    response = %Q{
<?xml version="1.0" encoding="UTF-8"?>
<hash>
  <@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655)>
    <+supporter/address>
      <modified type="integer">1234157216</modified>
      <type>+supporter/address</type>
      <value>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(+address$id=1482527)</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1482533)</canonical-id>

    </+supporter/address>
    <+supporter/role type="array">
      <+supporter/role>
        <+supporter/role>
          <modified type="integer">1222406918</modified>
          <type>+supporter/role</type>
          <value>ActiveLeader</value>
          <position nil="true"></position>
          <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1320742)</canonical-id>

        </+supporter/role>
      </+supporter/role>
      <+supporter/role>
        <+supporter/role>
          <modified type="integer">1222406919</modified>
          <type>+supporter/role</type>
          <value>ActiveMember</value>
          <position nil="true"></position>

          <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1320743)</canonical-id>
        </+supporter/role>
      </+supporter/role>
      <+supporter/role>
        <+supporter/role>
          <modified type="integer">1222406921</modified>
          <type>+supporter/role</type>
          <value>Donor</value>

          <position nil="true"></position>
          <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1320744)</canonical-id>
        </+supporter/role>
      </+supporter/role>
    </+supporter/role>
    <+supporter/last-name>
      <modified type="integer">1222406869</modified>
      <type>+supporter/last_name</type>

      <value>Whelan</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392678)</canonical-id>
    </+supporter/last-name>
    <+supporter/phone>
      <modified type="integer">1235715630</modified>
      <type>+supporter/phone</type>

      <value>123 456-7890</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392674)</canonical-id>
    </+supporter/phone>
    <+supporter/leader/connections type="array"/>
    <+supporter/first-name>
      <modified type="integer">1222406866</modified>
      <type>+supporter/first_name</type>

      <value>John</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392679)</canonical-id>
    </+supporter/first-name>
    <+supporter/modified>
      <modified type="integer">1207957123</modified>
      <type>+supporter/modified</type>

      <value type="integer">1235715630</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392656)</canonical-id>
    </+supporter/modified>
    <+supporter/leader/primary-connection>
      <modified type="integer">1234142487</modified>
      <type>+supporter/leader/primary_connection</type>

      <value>@!72CD.A072.157E.A9C6!0000.0000.3B9A.CA0C!0000.0000.3B9A.CA35</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1346257/1346258)</canonical-id>
    </+supporter/leader/primary-connection>
    <+supporter/leader>
      <modified type="integer">1234142487</modified>
      <type>+supporter/leader</type>

      <value>true</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1346257)</canonical-id>
    </+supporter/leader>
    <+supporter/modified-by type="array"/>
    <+supporter/kintera-id>
      <modified type="integer">1188823252</modified>
      <type>+supporter/kintera_id</type>

      <value>182839851</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392657)</canonical-id>
    </+supporter/kintera-id>
    <+supporter/email>
      <modified type="integer">1235715620</modified>
      <type>+supporter/email</type>

      <value>john.whelan@comcast.net</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392666)</canonical-id>
    </+supporter/email>
    <+supporter/lllid type="array">
      <+supporter/lllid>
        <+supporter/lllid>
          <modified type="integer">1233186733</modified>
          <type>+supporter/lllid</type>

          <value>@llli*john.whelan</value>
          <position type="integer">1</position>
          <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392690)</canonical-id>
        </+supporter/lllid>
      </+supporter/lllid>
      <+supporter/lllid>
        <+supporter/lllid>
          <modified type="integer">1233186733</modified>

          <type>+supporter/lllid</type>
          <value>@llli*johnw</value>
          <position type="integer">2</position>
          <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1185414)</canonical-id>
        </+supporter/lllid>
      </+supporter/lllid>
      <+supporter/lllid>
        <+supporter/lllid>
          <modified type="integer">1233186733</modified>

          <type>+supporter/lllid</type>
          <value>@llli*jw</value>
          <position type="integer">3</position>
          <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1186260)</canonical-id>
        </+supporter/lllid>
      </+supporter/lllid>
    </+supporter/lllid>

    <+supporter>
      <modified type="integer">1235715630</modified>
      <type>+supporter</type>
      <value>@!72CD.A072.157E.A9C6!0000.0000.3B9A.F8A9</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655)</canonical-id>
    </+supporter>

  </@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655)>
</hash>

<hash>
  <@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480)>
    <+supporter/role type="array">
      <+supporter/role>
        <+supporter/role>
          <modified type="integer">1235505448</modified>
          <type>+supporter/role</type>
          <value>Donor</value>

          <position type="integer">0</position>
          <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/1389955)</canonical-id>
        </+supporter/role>
      </+supporter/role>
      <+supporter/role>
        <+supporter/role>
          <modified type="integer">1234476471</modified>
          <type>+supporter/role</type>

          <value>ActiveMember</value>
          <position type="integer">1</position>
          <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/1581731)</canonical-id>
        </+supporter/role>
      </+supporter/role>
    </+supporter/role>
    <+supporter/last-name>
      <modified type="integer">1220633756</modified>

      <type>+supporter/last_name</type>
      <value>Mell</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785502)</canonical-id>
    </+supporter/last-name>
    <+supporter/phone>
      <modified type="integer">1234485583</modified>

      <type>+supporter/phone</type>
      <value>415.455.8812-6</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785498)</canonical-id>
    </+supporter/phone>
    <+supporter/first-name>
      <modified type="integer">1235702731</modified>

      <type>+supporter/first_name</type>
      <value>Michael</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785503)</canonical-id>
    </+supporter/first-name>
    <+supporter/modified>
      <modified type="integer">1212563386</modified>

      <type>+supporter/modified</type>
      <value type="integer">1235702731</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785515)</canonical-id>
    </+supporter/modified>
    <+supporter/modified-by type="array"/>
    <+supporter/kintera-id>
      <modified type="integer">1215275327</modified>

      <type>+supporter/kintera_id</type>
      <value>179791050</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785481)</canonical-id>
    </+supporter/kintera-id>
    <+supporter/email>
      <modified type="integer">1234485907</modified>

      <type>+supporter/email</type>
      <value>mike2@nthwave.net</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785490)</canonical-id>
    </+supporter/email>
    <+supporter/lllid type="array">
      <+supporter/lllid>
        <+supporter/lllid>
          <modified type="integer">1231954097</modified>

          <type>+supporter/lllid</type>
          <value>@llli*mike.mell</value>
          <position type="integer">1</position>
          <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785517)</canonical-id>
        </+supporter/lllid>
      </+supporter/lllid>
      <+supporter/lllid>
        <+supporter/lllid>
          <modified type="integer">1233187283</modified>

          <type>+supporter/lllid</type>
          <value>@llli*mike</value>
          <position type="integer">2</position>
          <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/1028589)</canonical-id>
        </+supporter/lllid>
      </+supporter/lllid>
      <+supporter/lllid>
        <+supporter/lllid>
          <modified type="integer">1233187283</modified>

          <type>+supporter/lllid</type>
          <value>@llli*mmell</value>
          <position type="integer">3</position>
          <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/1185964)</canonical-id>
        </+supporter/lllid>
      </+supporter/lllid>
    </+supporter/lllid>

    <+supporter>
      <modified type="integer">1235702731</modified>
      <type>+supporter</type>
      <value>@!72CD.A072.157E.A9C6!0000.0000.3B9A.CA17</value>
      <position nil="true"></position>
      <canonical-id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480)</canonical-id>
    </+supporter>

  </@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480)>
</hash>
}
    Polydata.stubs(:polyxri_post).returns(response)
    polydata_cache = PolydataCache.find_by_request(request)
    assert(polydata_cache)
    assert_equal(2, polydata_cache.polydata_cached_canonical_ids.size)
    assert_equal(polydata_cache.polydata_cached_canonical_ids[0], '@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655)')
    assert_equal(polydata_cache.polydata_cached_canonical_ids[1], '@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480)')
    PolydataCache.prune_cache(polydata_request, '@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655),@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480)')
    polydata_cache = PolydataCache.find_by_request(request)
    assert_nil(polydata_cache)
    
  end
end # /class PolyDataTest
