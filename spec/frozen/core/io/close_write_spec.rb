require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "IO#close_write" do
  before :each do
    @io = IO.popen 'cat', 'r+'
    @path = tmp('io.close.txt')
  end

  after :each do
    @io.close unless @io.closed?
  end

  it "closes the write end of a duplex I/O stream" do
    @io.close_write

    lambda { @io.write "attempt to write" }.should raise_error(IOError)
  end

  it "raises an IOError on subsequent invocations" do
    @io.close_write

    lambda { @io.close_write }.should raise_error(IOError)
  end

  it "allows subsequent invocation of close" do
    @io.close_write

    lambda { @io.close }.should_not raise_error
  end

  it "raises an IOError if the stream is readable and not duplexed" do
    io = File.open @path, 'w+'

    begin
      lambda { io.close_write }.should raise_error(IOError)
    ensure
      io.close unless io.closed?
    end
    File.unlink(@path)
  end

  it "closes the stream if it is neither readable nor duplexed" do
    io = File.open @path, 'w'

    io.close_write

    io.closed?.should == true
    File.unlink @path
  end

  it "flushes and closes the write stream" do
    @io.puts '12345'

    @io.close_write

    @io.read.should == "12345\n"
  end

  it "raises IOError on closed stream" do
    @io.close

    lambda { @io.close_write }.should raise_error(IOError)
  end
end
