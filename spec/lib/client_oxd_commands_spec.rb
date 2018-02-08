require 'spec_helper'

describe ClientOxdCommands do
	before do
		@oxd_command = ClientOxdCommands.new
	end

	describe "#setup_client" do
		it 'sets client_id, client_secret and oxd_id' do
		    @oxd_command.setup_client
		    expect(Oxd.config.client_id).not_to be_nil
		    expect(Oxd.config.client_secret).not_to be_nil
		    expect(Oxd.config.oxd_id).not_to be_nil
		end
	end

	describe "#get_client_token" do
		it 'returns protection_access_token' do
		    @oxd_command.get_client_token
		    expect(Oxd.config.protection_access_token).not_to be_nil
		end
	end

	describe "#introspect_access_token" do
		it 'returns response object' do
		    response = @oxd_command.introspect_access_token
		    expect(response).not_to be_nil
		    expect(response['token_type']).to eq("bearer")
		    expect(response['active']).to be_present
		    expect(response['client_id']).to be_present
		    expect(response['scopes']).to be_present
		end
	end

	describe "#register_site" do
		it 'returns oxd_id' do
		    @oxd_command.register_site
		    expect(Oxd.config.oxd_id).not_to be_nil
		end
	end

	describe "#oxdConfig" do
		it 'returns configuration object' do
		    oxdConfig = @oxd_command.oxdConfig
		    expect(oxdConfig).to be_an_instance_of(Oxd::Configuration) 
		end
	end

	describe "#get_authorization_url" do
		it 'returns authorization_url' do
		    authorization_url = @oxd_command.get_authorization_url
		    expect(authorization_url).to match(/client_id/)
		end

		it 'accepts acr_values as optional params' do
		    authorization_url = @oxd_command.get_authorization_url(["basic", "gplus"])
		    expect(authorization_url).to match(/basic/)
		    expect(authorization_url).to match(/gplus/)
		end
	end
	
	describe "#get_tokens_by_code" do
		it 'returns access_token' do
			code = "I6IjIifX0"
			state = "69krk8qjnshi4nc18n5rpeia4g"
			client_oxd_cmd = double("ClientOxdCommands")
			allow(client_oxd_cmd).to receive(:get_tokens_by_code).and_return("mock-token")
			access_token = client_oxd_cmd.get_tokens_by_code(code, state)
			expect(access_token).to eq("mock-token")
		end
	end

	describe "#get_access_token_by_refresh_token" do
		it 'returns access_token' do
			client_oxd_cmd = double("ClientOxdCommands")
			allow(client_oxd_cmd).to receive(:get_access_token_by_refresh_token).and_return("mock-token")
			access_token = client_oxd_cmd.get_access_token_by_refresh_token
			expect(access_token).to eq("mock-token")
		end
	end

	describe "#get_user_info" do
		it 'returns user claims' do
			client_oxd_cmd = double("ClientOxdCommands")
			allow(client_oxd_cmd).to receive(:get_user_info).and_return({"name": "mocky"})
			user_claims = client_oxd_cmd.get_user_info("257095f0-d0b4-4667-8e56-7cd48e490a77")
			expect(user_claims).to eq({"name": "mocky"})
		end

		it 'raises error for invalid arguments' do
			# Empty access token should raise error
			expect{ @oxd_command.get_user_info("") }.to raise_error(RuntimeError)
		end
	end

	describe "#get_logout_uri" do
		it 'returns logout uri' do
			Oxd.config.id_token = "eyJraWQiOiI3ZjUxYjM5Mi0wOTFlLTQ1NmYtODAyZS01ZjA5OWQzZDZhNWMiLCJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2dsdXVzZXJ2ZXIuY29tIiwiYXVkIjoiQCEzRENCLkRFMzIuM0QwRS5EMTY1ITAwMDEhMkFDNi5BOEQzITAwMDghMjUxMS4yQUQ0LjExOTYuNEE1MSIsImV4cCI6MTUxODA3MzA3MCwiaWF0IjoxNTE4MDY5NDcwLCJhY3IiOiJiYXNpYyBkdW8iLCJhbXIiOltdLCJub25jZSI6InJoMmphYWxwaWVobTM5Y2xyc2dvNWthMTNtIiwiYXV0aF90aW1lIjoxNTE4MDY5NDY4LCJhdF9oYXNoIjoiYWxFc3N3RE01RFVRVjNXQXdrWE5vZyIsIm94T3BlbklEQ29ubmVjdFZlcnNpb24iOiJvcGVuaWRjb25uZWN0LTEuMCIsInN1YiI6ImVEOEdTaTdFc2ZPd0tpU3RFczRYdHl1Qm84UTQ3SXpQcEROLW1lelFBS0EifQ.R7jPtZ2vTsS3nZNZO4B4P099RcPBgV-KsA3J1zSAgwNbvEUorIoddQZU6pWkdR6fsIjnEzmakKf02TE6lYJApTpT-lqMves1OtflrG9gwnRcf6Nl1WnvgwuXnavS6j7Q63YEEmmbuNtxTSE4fDw-EsnyZqtzeerdUv0RDzjJNSqfmcsAM0SJ_9FTommNOo8nJBim-2fHY9fUoSxC73_2CrFK0xOe-52CkjVVV375ZrYaAIBqOusOMj0PcDCUDOIMJgnGOLcv5CR6D04KgzD4p4T3aC8k3KMdxIbyASHnec4VQjIsLXZldyKRSQaBbOM3dmO4HczsoTsrQ6g04DyKzw"
		    
		    logout_uri = @oxd_command.get_logout_uri
		    expect(logout_uri).to match(/end_session/)

		    # called wiht OPTIONAL state
		    logout_uri_with_state = @oxd_command.get_logout_uri("some-s")
		    expect(logout_uri_with_state).to match(/end_session/)

		    # called wiht OPTIONAL session_state
		    logout_uri_with_sstate = @oxd_command.get_logout_uri("","some-ss")
		    expect(logout_uri_with_sstate).to match(/end_session/)

		    # called wiht OPTIONAL state + session_state
		    logout_uri_with_state_sstate = @oxd_command.get_logout_uri("some-s","some-ss")
		    expect(logout_uri_with_state_sstate).to match(/end_session/)
		end
	end

	describe "#update_site" do
		it 'updates website registration' do
			Oxd.config.post_logout_redirect_uri = "https://client.example.com/cb"
		    status = @oxd_command.update_site
		    expect(status).to be true
		end
	end
end