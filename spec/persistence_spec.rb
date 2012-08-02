describe Hyro::Persistence do
  let!(:klass) do
    class MAJSubclass < Hyro::Base
      model_attribute :id, :name, :updated_at
    end
    MAJSubclass.instance_variable_set(:@configuration, nil)
    MAJSubclass.instance_variable_set(:@connection, nil)
    MAJSubclass.configure do |conf|
      conf.root_name = "widget"
      conf.root_name_plural = "widgets"
      conf.base_url = "http://localtest.host"
      conf.base_path = "/widgets"
      conf.auth_type = "Bearer"
      conf.auth_token = "SEKRET"
      conf.transforms = {
        "updated_at" => Hyro::Transform::Time
      }
    end
    MAJSubclass
  end
  
  describe "#save!" do
    describe "new object" do
      it "should raise when unknown attributes are returned by server" do
        stub_request(:post, "http://localtest.host/widgets").
          with(:body => "{\"widget\":{\"name\":\"Neverknown\"}}",
            :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 201, :body => JSON.pretty_generate({
            "widget" => {
              "id" => 1,
              "name" => "Neverknown",
              "welp" => "bolth"
            }
          }), :headers => {'Content-Type'=>'application/json'})
      
        test = MAJSubclass.new( :name => "Neverknown")
        lambda { test.save! }.should raise_error(Hyro::UnknownAttribute)
      end
    
      it "should return object with ID" do
        stub_request(:post, "http://localtest.host/widgets").
          with(:body => "{\"widget\":{\"name\":\"Neverknown\"}}",
            :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 201, :body => JSON.pretty_generate({
            "widget" => {
              "id" => 1,
              "name" => "Neverknown"
            }
          }), :headers => {'Content-Type'=>'application/json'})
      
        test = MAJSubclass.new( :name => "Neverknown")
        test.save!
        test.persisted?.should == true
        test.id.should == 1
      end
    end
    
    describe "existing object" do
      let!(:instance) do
        stub_request(:get, "http://localtest.host/widgets/100").
          with(:headers => {'Accept'=>'application/json'}).
          to_return(:status => 200, :body => JSON.pretty_generate({
            "widget" => {
              "id" => 100,
              "name" => "Neverknown",
              "updated_at" => '2012-01-25T10:20:33Z'
            }
          }), :headers => {'Content-Type'=>'application/json'})
      
        MAJSubclass.find(100)
      end
      
      it "should return updated object" do
        stub_request(:put, "http://localtest.host/widgets/100").
          with(:body => "{\"widget\":{\"id\":100,\"name\":\"Wasknown\",\"updated_at\":\"2012-01-25T10:20:33Z\"}}",
            :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => JSON.pretty_generate({
            "widget" => {
              "id" => 100,
              "name" => "Wasknown",
              "updated_at" => '2012-01-25T10:20:33Z'
            }
          }), :headers => {'Content-Type'=>'application/json'})
      
        instance.name_changed?.should == false
        instance.name = "Wasknown"
        instance.name_was.should == "Neverknown"
        instance.name_changed?.should == true
        instance.save!
        instance.id.should == 100
        instance.name.should == "Wasknown"
      end
      
      it "should handle time decoding & encoding" do
        instance.updated_at.should == Time.utc(2012, 1, 25, 10, 20, 33)
        now = Time.now.utc
        instance.updated_at = now
        now_s = now.strftime("%Y-%m-%dT%H:%M:%SZ")
        
        stub_request(:put, "http://localtest.host/widgets/100").
          with(:body => "{\"widget\":{\"id\":100,\"name\":\"Neverknown\",\"updated_at\":\"#{now_s}\"}}",
            :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => JSON.pretty_generate({
            "widget" => {
              "id" => 100,
              "name" => "Wasknown",
              "updated_at" => now_s
            }
          }), :headers => {'Content-Type'=>'application/json'})
        
        instance.save!
      
      end
      
    end
  end
end
