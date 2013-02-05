describe Hyro::Finders do
  let!(:klass) do
    class TestSubclass < Hyro::Base
      model_attribute :id, :name
    end
    TestSubclass.instance_variable_set(:@configuration, nil)
    TestSubclass.instance_variable_set(:@connection, nil)
    TestSubclass.configure do |conf|
      conf.root_name = "widget"
      conf.root_name_plural = "widgets"
      conf.base_url = "http://localtest.host"
      conf.base_path = "/widgets"
      conf.auth_type = "Bearer"
      conf.auth_token = "SEKRET"
    end
    TestSubclass
  end
  
  describe ".find" do
    it "should return found instance" do
      stub_request(:get, "http://localtest.host/widgets/1").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(:status => 200, :body => JSON.pretty_generate({
          "widget" => {
            "id" => 1,
            "name" => "Test Widget"
          }
        }), :headers => {'Content-Type'=>'application/json'})
      
      test = TestSubclass.find(1)
      test.should be_kind_of(TestSubclass)
      test.id.should == 1
      test.name.should == "Test Widget"
    end
    
    it "should given params return found instance" do
      stub_request(:get, "http://localtest.host/widgets/1?mars=true&maj=really+true").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(:status => 200, :body => JSON.pretty_generate({
          "widget" => {
            "id" => 1,
            "name" => "Test Widget"
          }
        }), :headers => {'Content-Type'=>'application/json'})
      
      test = TestSubclass.find(1, { mars: true, maj: 'really true'})
      test.should be_kind_of(TestSubclass)
      test.id.should == 1
      test.name.should == "Test Widget"
    end
    
    it "should return found collection" do
      stub_request(:get, "http://localtest.host/widgets").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(:status => 200, :body => JSON.pretty_generate({
          "widgets" => [{
            "id" => 1,
            "name" => "Test Widget 1"
          },{
            "id" => 2,
            "name" => "Test Widget 2"
          },{
            "id" => 3,
            "name" => "Test Widget 3"
          }]
        }), :headers => {'Content-Type'=>'application/json'})
      
      tests = TestSubclass.find()
      tests.should be_kind_of(Array)
      tests.size.should == 3
      tests.each_with_index do |test, i|
        num = i + 1
        test.should be_kind_of(TestSubclass)
        test.id.should == num
        test.name.should == "Test Widget #{num}"
      end
    end
    
    it "should given params return found collection" do
      stub_request(:get, "http://localtest.host/widgets?name=Test+Widget+2").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(:status => 200, :body => JSON.pretty_generate({
          "widgets" => [{
            "id" => 2,
            "name" => "Test Widget 2"
          }]
        }), :headers => {'Content-Type'=>'application/json'})
      
      tests = TestSubclass.find( name: 'Test Widget 2' )
      tests.should be_kind_of(Array)
      tests.size.should == 1

      tests[0].should be_kind_of(TestSubclass)
      tests[0].id.should == 2
      tests[0].name.should == "Test Widget 2"
    end
  end
end
