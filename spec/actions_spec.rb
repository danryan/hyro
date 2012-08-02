describe Hyro::Actions do
  let!(:klass) do
    class TestSubclass < Hyro::Base
      model_attribute :id, :name, :state
    end
    TestSubclass.instance_variable_set(:@configuration, nil)
    TestSubclass.instance_variable_set(:@connection, nil)
    TestSubclass
  end
  
  describe "#action" do
    let!(:instance) do
      TestSubclass.configure do |conf|
        conf.root_name = "widget"
        conf.root_name_plural = "widgets"
        conf.base_url = "http://localtest.host"
        conf.base_path = "/widgets"
        conf.auth_type = "Bearer"
        conf.auth_token = "SEKRET"
      end
      stub_request(:get, "http://localtest.host/widgets/100").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(:status => 200, :body => JSON.pretty_generate({
          "widget" => {
            "id" => 100,
            "name" => "Neverknown",
            "state" => "unordered"
          }
        }), :headers => {'Content-Type'=>'application/json'})
      
      TestSubclass.find(100)
    end
    
    
    it "should raise when missing action config" do
      lambda { instance.action("order") }.should raise_error(Hyro::Misconfigured)
    end
    
    it "should return object new state" do
      TestSubclass.configure do |conf|
        conf.actions = {
          "member" => {
            "order" => "put"
          }
        }
      end
      
      stub_request(:put, "http://localtest.host/widgets/100/order").
        with(:body => "{\"widget\":{\"id\":100,\"name\":\"Neverknown\",\"state\":\"unordered\"}}",
          :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => JSON.pretty_generate({
          "widget" => {
            "id" => 100,
            "name" => "Neverknown",
            "state" => "ordered"
          }
        }), :headers => {'Content-Type'=>'application/json'})
      
      instance.action("order")
      instance.state.should == "ordered"
      
    end
  end
end
