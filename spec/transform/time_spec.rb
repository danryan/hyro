describe Hyro::Transform::Time do

  describe ".encode" do
    it "should emit ISO-8601" do
      Hyro::Transform::Time.encode(Time.utc(2012, 1, 25, 10, 20, 33)).should == '2012-01-25T10:20:33Z'
    end

    it "should handle nil" do
      Hyro::Transform::Time.encode(nil).should == nil
    end
  end

  describe ".decode" do
    it "should accept ISO-8601" do
      Hyro::Transform::Time.decode('2012-01-25T10:20:33Z').should == Time.utc(2012, 1, 25, 10, 20, 33)
    end

    it "should handle nil" do
      Hyro::Transform::Time.decode(nil).should == nil
    end
  end

end
