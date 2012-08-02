describe Hyro::Auth do
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
    end
    TestSubclass
  end
  
  it "passes auth headers" do
    TestSubclass.configure do |conf|
      conf.auth_type = "Bearer"
      conf.auth_token = "SEKRET"
    end
    
    request = stub_request(:get, "http://localtest.host/widgets/1").
      with(:headers => {'Accept'=>'application/json', 'Authorization'=>'Bearer SEKRET'}). # <- stub contains auth header
      to_return(:status => 200, :body => JSON.pretty_generate({
        "widget" => {
          "id" => 1,
          "name" => "Test Widget"
        }
      }), :headers => {'Content-Type'=>'application/json'})
    
    klass.find!(1)
    request.should have_been_made
  end
  
  it "fails when missing config" do
    lambda { klass.find!(1) }.should raise_error(Hyro::Misconfigured)
  end
end
