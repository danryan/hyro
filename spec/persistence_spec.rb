describe Hyro::Persistence do
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
  
  describe "#save!" do
    describe "new object" do
      it "should raise when unknown attributes are returned by server" do
        stub_request(:post, "http://localtest.host/widgets").
          with(:body => "{\"name\":\"Neverknown\"}",
            :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 201, :body => JSON.pretty_generate({
            "widget" => {
              "id" => 1,
              "name" => "Neverknown",
              "welp" => "bolth"
            }
          }), :headers => {'Content-Type'=>'application/json'})
      
        test = TestSubclass.new( :name => "Neverknown")
        lambda { test.save! }.should raise_error(Hyro::UnknownAttribute)
      end
    
      it "should return object with ID" do
        stub_request(:post, "http://localtest.host/widgets").
          with(:body => "{\"name\":\"Neverknown\"}",
            :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 201, :body => JSON.pretty_generate({
            "widget" => {
              "id" => 1,
              "name" => "Neverknown"
            }
          }), :headers => {'Content-Type'=>'application/json'})
      
        test = TestSubclass.new( :name => "Neverknown")
        test.save!
        test.persisted?.should == true
        test.id.should == 1
      end
    end
    
    describe "existing object" do
      it "should return updated object" do
        stub_request(:get, "http://localtest.host/widgets/100").
          with(:headers => {'Accept'=>'application/json'}).
          to_return(:status => 200, :body => JSON.pretty_generate({
            "widget" => {
              "id" => 100,
              "name" => "Neverknown"
            }
          }), :headers => {'Content-Type'=>'application/json'})
      
        test = TestSubclass.find(100)
      
        stub_request(:put, "http://localtest.host/widgets/100").
          with(:body => "{\"id\":100,\"name\":\"Wasknown\"}",
            :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => JSON.pretty_generate({
            "widget" => {
              "id" => 100,
              "name" => "Wasknown"
            }
          }), :headers => {'Content-Type'=>'application/json'})
      
        test.name_changed?.should == false
        test.name = "Wasknown"
        test.name_was.should == "Neverknown"
        test.name_changed?.should == true
        test.save!
        test.id.should == 100
        test.name.should == "Wasknown"
      end
      
    end
  end
end
