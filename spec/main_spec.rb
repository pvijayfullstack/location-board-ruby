require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "The Main App" do

  describe "GET /" do

    it "is successful" do
      get '/'
      last_response.should be_ok
    end

  end

end