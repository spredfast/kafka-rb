require File.dirname(__FILE__) + '/spec_helper'

class IOTest
  include Kafka::IO
end

describe IO do

  before(:each) do
    @mocked_socket = mock(TCPSocket)
    TCPSocket.stub!(:new).and_return(@mocked_socket) # don't use a real socket
    @io = IOTest.new
    @io.connect("somehost", 9093)
  end

  describe "default methods" do
    it "has a socket, a host and a port" do
      [:socket, :host, :port].each do |m|
        @io.should respond_to(m.to_sym)
      end
    end

    it "raises an exception if no host and port is specified" do
      lambda {
        io = IOTest.new
        io.connect
      }.should raise_error(ArgumentError)
    end
    
    it "should remember the port and host on connect" do
      @io.connect("somehost", 9093)
      @io.host.should eql("somehost")
      @io.port.should eql(9093)
    end

    it "should write to a socket" do
      data = "some data"
      @mocked_socket.should_receive(:write).with(data).and_return(9)
      @io.write(data).should eql(9)
    end

    it "should disconnect" do
      @io.should respond_to(:disconnect)
      @mocked_socket.should_receive(:close).and_return(nil)
      @io.disconnect
    end

    it "should reconnect" do
      @mocked_socket.should_receive(:close)
      @io.should_receive(:connect)
      @io.reconnect
    end

    it "should reconnect on a broken pipe error" do
      [Errno::ECONNABORTED, Errno::EPIPE, Errno::ECONNRESET].each do |error|
        @mocked_socket.should_receive(:write).exactly(:twice).and_raise(error)
        @mocked_socket.should_receive(:close).exactly(:once).and_return(nil)
        lambda {
          @io.write("some data to send")
        }.should raise_error(error)
      end
    end
  end
end
