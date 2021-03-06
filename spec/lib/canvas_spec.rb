require 'rails_helper'

describe Canvas do
  before do
    @course_id = 11
    @token = 'test'
    @base_uri = 'http://www.example.com'    
    @canvas_authentication = FactoryGirl.create(:authentication, :provider => 'canvas', :token => @token, :provider_url => @base_uri)
    @api = Canvas.new(@canvas_authentication.provider_url, @canvas_authentication.token)
    @external_tool_id = 1
    lti_options = {
      launch_url: 'http://www.example.com/launch'
    }
    @tool_config = {
      "config_type" => "by_xml",
      "config_xml" => Lti::Canvas.config_xml(lti_options)
    }
  end

  describe "api_put_request" do
    it "calls the given url with a PUT request" do
      payload = {}
      result = http_party_put_response
      expect(HTTParty).to receive(:put).with("#{@base_uri}/api/v1/courses", :headers => @api.headers, :body => payload).and_return(result)
      @api.api_put_request("courses", payload)
    end
  end

  describe "api_post_request" do
    it "calls the given url with a POST request" do
      payload = {}
      result = http_party_post_response
      expect(HTTParty).to receive(:post).with("#{@base_uri}/api/v1/courses", :headers => @api.headers, :body => payload).and_return(result)
      @api.api_post_request("courses", payload)
    end
  end

  describe "api_get_request" do
    it "calls the given url with a GET request" do
      result = http_party_get_response
      expect(HTTParty).to receive(:get).with("#{@base_uri}/api/v1/courses", :headers => @api.headers).and_return(result)
      @api.api_get_request("courses")
    end
  end
  
  describe "check_result" do
    it "should raise an UnauthorizedException if 401 not authorized" do
      result = http_party_get_response(401, 'Unauthorized')
      expect { @api.check_result(result.response) }.to raise_exception(Canvas::UnauthorizedException)
    end    
    it "should raise an NotFoundException if 404 not found" do
      result = http_party_get_response(404, 'Not Found')
      expect { @api.check_result(result) }.to raise_exception(Canvas::NotFoundException)
    end
    it "should raise an InvalidRequestException if canvas call fails" do
      result = http_party_get_response(500, 'Internal Server Error', "{errors:'Something terrible'}")
      expect { @api.check_result(result) }.to raise_exception(Canvas::InvalidRequestException)
    end
    it "should return the result for a 200" do
      result = http_party_get_response
      expect(@api.check_result(result)).to eq(result)
    end
    it "should return the result for a 201" do
      result = http_party_get_response(201)
      expect(@api.check_result(result)).to eq(result)
    end
  end

  describe "courses" do
    it "should retrieve courses from the Canvas API" do
      courses = @api.courses
      expect(courses.length).to be > 0
    end
  end

  describe "is_account_admin" do
    it "Returns true when the user is an account admin" do
      stub_request(:get, %r|http[s]*://www.example.com/api/v1/accounts/self|).
        to_return(
          :status => 200, 
          :body => "", 
          :headers => canvas_headers)
      @api.is_account_admin
    end
    it "Returns false when the user is not an account admin" do
      stub_request(:get, %r|http[s]*://www.example.com/api/v1/accounts/self|).
        to_return(
          :status => 401, 
          :body => "", 
          :headers => canvas_headers)
      @api.is_account_admin
    end
  end

  describe "all_accounts" do
    it "retrieves all accounts and subaccounts" do
      all = @api.all_accounts
      expect(all.length).to be > 0
    end
  end

  describe "accounts" do
    it "should retrieve accounts from the Canvas API" do
      accounts = @api.accounts
      expect(accounts.length).to be > 0
    end
  end

  describe "sub_accounts" do
    it "should retrieve sub accounts from the Canvas API for the given account" do
      accounts = @api.sub_accounts("43460000000000001")
      expect(accounts.length).to be > 0
      manual = accounts.find{|a| a['id'] == 43460000000000002}
      expect(manual).to be_present
      demo = accounts.find{|a| a['id'] == 43460000000000017}
      expect(demo).to be_present
    end
  end

  describe "get_course_lti_tools" do
    it "should find installed LTI tools for the given course" do
      tools = @api.get_course_lti_tools(@course_id)
      expect(tools.first['consumer_key']).to eq('fake')
    end
  end

  describe "update_course_lti_tool" do
    it "should find installed LTI tools for the given course" do
      tool = @api.update_course_lti_tool(@course_id, @external_tool_id, @tool_config)
      expect(tool['consumer_key']).to eq('fake')
    end
  end

  describe "create_course_lti_tool" do
    it "should find installed LTI tools for the given course" do
      tool = @api.create_course_lti_tool(@course_id, @tool_config)
      expect(tool['consumer_key']).to eq('fake')
    end
  end

end