module Polydata
  
  # Manage the xml$v2 format
  class XmlV2 < Hash
    
    # FIXME use libxml-ruby
    def self.instance_to_hash(instance_rexml_doc)
      hsh = new
      return hsh if instance_rexml_doc.nil?
      query_path = REXML::XPath.first(instance_rexml_doc, "query_path")
      return nil if query_path.nil? # instance_rexml_doc is one of the instance elements
      hsh[:query_path] = query_path.text
      hsh[:modified] = get_element(instance_rexml_doc, "modified")
      hsh[:modified] = Time.at(hsh[:modified].to_i) if hsh[:modified]
      hsh[:canonical_id] = get_element(instance_rexml_doc, "canonical_id")
      hsh[:position] = get_element(instance_rexml_doc, "position")
      hsh[:query_path] = get_element(instance_rexml_doc, "query_path")
      hsh[:value] = get_element(instance_rexml_doc, "value")
      hsh[:value] = nil if hsh[:value] == '$null'
  
      instance_rexml_doc.elements.each { |e| 
        next if ['value', 'modified', 'position', 'query_path', 'canonical_id'].include?(e.name)
        if !e.attributes['type'].nil? and e.attributes['type'] == 'array'
          query_path = e.attributes['query_path']
          hsh[ query_path ] = [] 
          e.elements.each { |e|
            hsh[query_path] << XmlV2.instance_to_hash(e) 
          }
        else
          ci = XmlV2.instance_to_hash(e)
          hsh[ci.query_path] = ci if ci
        end
      } 
  
      hsh
    end
    
    def self.get_element(ele, child_name)
      e = REXML::XPath.first(ele, child_name)
      e ? e.text : nil
    end
    
    def self.parse(response)
      doc = REXML::Document.new( response )
      status = REXML::XPath.first(doc, '/response/status')
      raise StandardError, "response is bad: #{response}" unless status and status.text == '$success'
      arr = []
      REXML::XPath.each(doc, '/response/instances/instance') { |e| arr << XmlV2.instance_to_hash(e) } 
      arr
    end
    
    def is_set?
      # self.is_a?(Array) or 
      !canonical_id.nil?
    end
    
    def value
      self[:value]
    end

    def modified
      self[:modified]
    end

    def canonical_id
      self[:canonical_id]
    end

    def position
      self[:position]
    end

    def query_path
      self[:query_path]
    end

    def to_s
      self[:value]
    end

  end

end

=begin
SAMPLE XML RESPONSE

<?xml version="1.0" encoding="UTF-8"?>
<instances>
<instance>
  <query_path>+supporter</query_path>
  <value>@!72CD.A072.157E.A9C6!0000.0000.3B9A.F8A9</value>
  <position></position>
  <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655)</canonical_id>
  <modified>1235715630</modified>

  <instance>
    <query_path>+supporter/address</query_path>
    <value>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(+address$id=1482527)</value>
    <position></position>
    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1482533)</canonical_id>
    <modified>1234157216</modified>
  </instance>

  <instance>
    <query_path>+supporter/email</query_path>
    <value>john.whelan@comcast.net</value>
    <position></position>
    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392666)</canonical_id>
    <modified>1235715620</modified>
  </instance>

  <instance>
    <query_path>+supporter/first_name</query_path>
    <value>John</value>
    <position></position>
    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392679)</canonical_id>
    <modified>1222406866</modified>
  </instance>

  <instance>
    <query_path>+supporter/kintera_id</query_path>
    <value>182839851</value>
    <position></position>
    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392657)</canonical_id>
    <modified>1188823252</modified>
  </instance>

  <instance>
    <query_path>+supporter/last_name</query_path>
    <value>Whelan</value>
    <position></position>
    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392678)</canonical_id>
    <modified>1222406869</modified>
  </instance>

  <instance>
    <query_path>+supporter/leader</query_path>
    <value>true</value>
    <position></position>
    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1346257)</canonical_id>
    <modified>1234142487</modified>
    <instance>

      <query_path>+supporter/leader/primary_connection</query_path>
      <value>@!72CD.A072.157E.A9C6!0000.0000.3B9A.CA0C!0000.0000.3B9A.CA35</value>
      <position></position>
      <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1346257/1346258)</canonical_id>
      <modified>1234142487</modified>
    </instance>
    <instance type="array" query_path="+supporter/leader/connections">

    </instance>
  </instance>
  <instance type="array" query_path="+supporter/lllid">
    <instance>
      <query_path>+supporter/lllid</query_path>
      <value>@llli*john.whelan</value>
      <position>1</position>

      <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392690)</canonical_id>
      <modified>1233186733</modified>
    </instance>
    <instance>
      <query_path>+supporter/lllid</query_path>
      <value>@llli*johnw</value>
      <position>2</position>

      <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1185414)</canonical_id>
      <modified>1233186733</modified>
    </instance>
    <instance>
      <query_path>+supporter/lllid</query_path>
      <value>@llli*jw</value>
      <position>3</position>

      <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1186260)</canonical_id>
      <modified>1233186733</modified>
    </instance>
  </instance>
  <instance>
    <query_path>+supporter/modified</query_path>
    <value>1235715630</value>

    <position></position>
    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392656)</canonical_id>
    <modified>1207957123</modified>
  </instance>
  <instance type="array" query_path="+supporter/modified_by">
  </instance>
  <instance>
    <query_path>+supporter/phone</query_path>

    <value>123 456-7890</value>
    <position></position>
    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/392674)</canonical_id>
    <modified>1235715630</modified>
  </instance>
  <instance type="array" query_path="+supporter/role">
    <instance>

      <query_path>+supporter/role</query_path>
      <value>ActiveLeader</value>
      <position></position>
      <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1320742)</canonical_id>
      <modified>1222406918</modified>
    </instance>
    <instance>

      <query_path>+supporter/role</query_path>
      <value>ActiveMember</value>
      <position></position>
      <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1320743)</canonical_id>
      <modified>1222406919</modified>
    </instance>
    <instance>

      <query_path>+supporter/role</query_path>
      <value>Donor</value>
      <position></position>
      <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(392655/1320744)</canonical_id>
      <modified>1222406921</modified>
    </instance>
  </instance>

</instance>

<instance>
  <query_path>+supporter</query_path>
  <value>@!72CD.A072.157E.A9C6!0000.0000.3B9A.CA17</value>
  <position></position>
  <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480)</canonical_id>
  <modified>1235702731</modified>

  <instance>
    <query_path>+supporter/address</query_path>
  </instance>
  <instance>
    <query_path>+supporter/email</query_path>
    <value>mike2@nthwave.net</value>
    <position></position>

    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785490)</canonical_id>
    <modified>1234485907</modified>
  </instance>
  <instance>
    <query_path>+supporter/first_name</query_path>
    <value>Michael</value>
    <position></position>

    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785503)</canonical_id>
    <modified>1235702731</modified>
  </instance>
  <instance>
    <query_path>+supporter/kintera_id</query_path>
    <value>179791050</value>

    <position></position>
    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785481)</canonical_id>
    <modified>1215275327</modified>
  </instance>
  <instance>
    <query_path>+supporter/last_name</query_path>
    <value>Mell</value>

    <position></position>
    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785502)</canonical_id>
    <modified>1220633756</modified>
  </instance>
  <instance>
    <query_path>+supporter/leader</query_path>
  </instance>

  <instance type="array" query_path="+supporter/lllid">
    <instance>
      <query_path>+supporter/lllid</query_path>
      <value>@llli*mike.mell</value>
      <position>1</position>
      <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785517)</canonical_id>
      <modified>1231954097</modified>

    </instance>
    <instance>
      <query_path>+supporter/lllid</query_path>
      <value>@llli*mike</value>
      <position>2</position>
      <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/1028589)</canonical_id>
      <modified>1233187283</modified>

    </instance>
    <instance>
      <query_path>+supporter/lllid</query_path>
      <value>@llli*mmell</value>
      <position>3</position>
      <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/1185964)</canonical_id>
      <modified>1233187283</modified>

    </instance>
  </instance>
  <instance>
    <query_path>+supporter/modified</query_path>
    <value>1235702731</value>
    <position></position>
    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785515)</canonical_id>

    <modified>1212563386</modified>
  </instance>
  <instance type="array" query_path="+supporter/modified_by">
  </instance>
  <instance>
    <query_path>+supporter/phone</query_path>
    <value>415.455.8812-6</value>

    <position></position>
    <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/785498)</canonical_id>
    <modified>1234485583</modified>
  </instance>
  <instance type="array" query_path="+supporter/role">
    <instance>
      <query_path>+supporter/role</query_path>

      <value>Donor</value>
      <position>0</position>
      <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/1389955)</canonical_id>
      <modified>1235505448</modified>
    </instance>
    <instance>
      <query_path>+supporter/role</query_path>

      <value>ActiveMember</value>
      <position>1</position>
      <canonical_id>@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6/(785480/1581731)</canonical_id>
      <modified>1234476471</modified>
    </instance>
  </instance>
</instance>

</instances>

=end
