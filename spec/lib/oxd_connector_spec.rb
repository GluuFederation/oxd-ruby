require 'spec_helper'

describe OxdConnector do
	before do
		@socket_connection = OxdConnector.new
	end

	describe "#validate_command" do
		it 'raises error for invalid command supplied' do
			@socket_connection.instance_variable_set :@command, "test"
		    expect{ @socket_connection.validate_command }.to raise_error(RuntimeError)
		end
	end

	describe "#oxd_socket_request" do
		it 'should connect to oxd server' do
		    expect{ @socket_connection.oxd_socket_request({"command": "test"}) }.not_to raise_error
		end
		it 'should return a response' do
			expect( @socket_connection.oxd_socket_request({"command": "test"}) ).not_to be_nil
		end
	end

	describe "#request" do
		context "when valid arguments are passed" do
			it 'should return a response object' do
				@socket_connection.instance_variable_set :@command, "get_authorization_url"
				@socket_connection.instance_variable_set :@params, {"oxd_id" => Oxd.config.oxd_id, "acr_values" => Oxd.config.acr_values}
			    expect( @socket_connection.request ).not_to be_nil
			end	
		end

		context "when command is not valid" do
			it 'should raise error' do
				@socket_connection.instance_variable_set :@command, "test"
			    expect{ @socket_connection.request }.to raise_error(RuntimeError)
			end		
		end
	end

	describe "#getResponseData" do
		context "when @response_object is empty" do
			it 'should == "Data is empty"' do
				expect(@socket_connection.getResponseData).to eq('Data is empty')
			end
		end
	end

	describe "#getData" do
		it "should be a Hash and should include('command', 'params')" do
			expect(@socket_connection.getData).to be_a(Hash)  
			expect(@socket_connection.getData).to include('command', 'params')
		end
	end

	describe "#is_json" do
		context "when passed argument is in JSON format" do
			it "returns true" do
				expect(@socket_connection.is_json? ('{"key1":"key1_val","kay2":"key2_val"}')).to be true
			end
		end
		context "when argument is not in JSON format" do
			it "return false" do
				expect(@socket_connection.is_json? ('ordinary non json string')).to be false
			end
		end
	end
end