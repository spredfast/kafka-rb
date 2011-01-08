require File.dirname(__FILE__) + '/spec_helper'

describe Message do

  before(:each) do
    @message = Message.new
  end

  describe "Kafka Message" do
    it "should have a default magic number" do
      Message::MAGIC_IDENTIFIER_DEFAULT.should eql(0)
    end

    it "should have a magic field, a checksum and a payload" do
      [:magic, :checksum, :payload].each do |field|
        @message.should respond_to(field.to_sym)
      end
    end

    it "should set a default value of zero" do
      @message.magic.should eql(Kafka::Message::MAGIC_IDENTIFIER_DEFAULT)
    end

    it "should allow to set a custom magic number" do
      @message = Message.new("ale", 1)
      @message.magic.should eql(1)
    end

    it "should calculate the checksum (crc32 of a given message)" do
      @message.payload = "ale"
      @message.calculate_checksum.should eql(1120192889)
      @message.payload = "alejandro"
      @message.calculate_checksum.should eql(2865078607)
    end

    it "should say if the message is valid using the crc32 signature" do
      @message.payload  = "alejandro"
      @message.checksum = 2865078607
      @message.valid?.should eql(true)
      @message.checksum = 0
      @message.valid?.should eql(false)
    end
  end
end
