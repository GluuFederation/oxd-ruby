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
		#it 'raises error for invalid arguments' do
			# Empty code should raise error		
		#	expect{ @oxd_command.get_tokens_by_code("", "") }.to raise_error(RuntimeError)
		#end
		#it 'raises error if response has error' do
		#	code = "I6IjIifX0"		    
		#	expect{ @oxd_command.get_tokens_by_code(code, "") }.to raise_error(RuntimeError)
		#end
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
		    logout_uri = @oxd_command.get_logout_uri("257095f0-d0b4-4667-8e56-7cd48e490a77")
		    expect(logout_uri).to match(/end_session/)

		    # called wiht OPTIONAL state
		    logout_uri_with_state = @oxd_command.get_logout_uri("257095f0-d0b4-4667-8e56-7cd48e490a77","some-s")
		    expect(logout_uri_with_state).to match(/end_session/)

		    # called wiht OPTIONAL session_state
		    logout_uri_with_sstate = @oxd_command.get_logout_uri("257095f0-d0b4-4667-8e56-7cd48e490a77","","some-ss")
		    expect(logout_uri_with_sstate).to match(/end_session/)

		    # called wiht OPTIONAL state + session_state
		    logout_uri_with_state_sstate = @oxd_command.get_logout_uri("257095f0-d0b4-4667-8e56-7cd48e490a77","some-s","some-ss")
		    expect(logout_uri_with_state_sstate).to match(/end_session/)
		end
	end

	describe "#update_site_registration" do
		it 'updates website registration' do
			Oxd.config.post_logout_redirect_uri = "https://client.example.com/cb"
		    status = @oxd_command.update_site_registration
		    expect(status).to be true
		end
	end
end