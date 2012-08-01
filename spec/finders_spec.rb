describe Hyro::Finders do
  let!(:klass) do
    class TestSubclass < Hyro::Base
      model_attribute :id, :name
    end
    TestSubclass.instance_variable_set(:@configuration, nil)
    TestSubclass.configure do |conf|
      conf.root_name = "widget"
      conf.root_name_plural = "widgets"
      conf.base_url = "http://localtest.host"
      conf.base_path = "/widgets"
      conf.authorization = "Bearer SEKRET"
    end
    TestSubclass
  end
  
  describe ".find" do
    it "should raise on unexpected args" do
      lambda { TestSubclass.find }.should raise_error(Hyro::Error)
    end
    
    it "should return found instance" do
      stub_request(:get, "http://localtest.host/widgets/1").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(:status => 200, :body => {
          "widget" => {
            "id" => 1,
            "name" => "Test Widget"
          }
        }.to_json, :headers => {'Content-Type'=>'application/json'})
      
      test = TestSubclass.find(1)
      test.should be_kind_of(TestSubclass)
      test.id.should == 1
      test.name.should == "Test Widget"
    end
    
    it "should given params return found instance" do
      stub_request(:get, "http://localtest.host/widgets/1?mars=true&maj=really+true").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(:status => 200, :body => {
          "widget" => {
            "id" => 1,
            "name" => "Test Widget"
          }
        }.to_json, :headers => {'Content-Type'=>'application/json'})
      
      test = TestSubclass.find(1, { mars: true, maj: 'really true'})
      test.should be_kind_of(TestSubclass)
      test.id.should == 1
      test.name.should == "Test Widget"
    end
  end
end
