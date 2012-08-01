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
    it "should raise on unexpected attributes" do
      stub_request(:post, "http://localtest.host/widgets").
        with(:body => "{\"id\":100,\"name\":\"Neverknown\"}",
          :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => {
          "widget" => {
            "id" => 1,
            "name" => "Test Widget",
            "welp" => "bolth"
          }
        }.to_json, :headers => {'Content-Type'=>'application/json'})
      
      test = TestSubclass.new( :id => 100, :name => "Neverknown")
      lambda { test.save! }.should raise_error(Hyro::UnknownAttribute)
    end
  end
end
