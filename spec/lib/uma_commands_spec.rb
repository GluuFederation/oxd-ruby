require 'spec_helper'

describe UMACommands do
	before do
		@uma_command = UMACommands.new
	end

	describe "#uma_add_resource" do
		it 'adds resources to @resources array' do
		    condition1 = {:httpMethods => ["GET"], :scopes => ["http://photoz.example.com/dev/actions/view"]}
	        condition2 = {:httpMethods => ["PUT", "POST"], :scopes => ["http://photoz.example.com/dev/actions/all","http://photoz.example.com/dev/actions/add"], :ticketScopes => ["http://photoz.example.com/dev/actions/add"]}

	        mock_resources_array = [{:path => "/photo", :conditions => [{:httpMethods=>["GET"],:scopes => ["http://photoz.example.com/dev/actions/view"]}, {:httpMethods => ["PUT","POST"],:scopes => ["http://photoz.example.com/dev/actions/all","http://photoz.example.com/dev/actions/add"],:ticketScopes => ["http://photoz.example.com/dev/actions/add"]}]}]

	        resources = @uma_command.uma_add_resource("/photo", condition1, condition2)
		    expect(resources).not_to be_nil
		    expect(resources).to match_array(mock_resources_array)
		end
	end

	describe "#uma_rs_protect" do
		it 'returns oxd_id' do
			@uma_command.instance_variable_set :@resources, [{:path => "/photo", :conditions => [{:httpMethods=>["GET"],:scopes => ["http://photoz.example.com/dev/actions/view"]}, {:httpMethods => ["PUT","POST"],:scopes => ["http://photoz.example.com/dev/actions/all","http://photoz.example.com/dev/actions/add"],:ticketScopes => ["http://photoz.example.com/dev/actions/add"]}]}]

		    oxd_id = @uma_command.uma_rs_protect
		    expect(oxd_id).not_to be_nil
		    expect(oxd_id).to eq(Oxd.config.oxd_id)
		end

		it 'raises error if @resources is not set' do
			expect{ @uma_command.uma_rs_protect }.to raise_error(RuntimeError)
		end

		it 'raises error if response has error' do
			@uma_command.instance_variable_set :@resources, [:paths => "/photo"]
			expect{ @uma_command.uma_rs_protect }.to raise_error(RuntimeError)
		end
	end

	describe "#uma_rp_get_rpt" do
		it 'returns rpt' do
		    rpt = @uma_command.uma_rp_get_rpt('false')
		    expect(rpt).not_to be_nil
		    expect(rpt).to eq(Oxd.config.rpt)
		end

		it 'raises error for invalid arguments' do
			expect{ @uma_command.uma_rp_get_rpt('any string') }.to raise_error(RuntimeError)
		end

		it 'returns new rpt if force_new param is set to "true"' do
			rpt = @uma_command.uma_rp_get_rpt('false')

		    new_rpt = @uma_command.uma_rp_get_rpt('true')
		    expect(new_rpt).not_to be_nil
		    expect(new_rpt).to eq(Oxd.config.rpt)
		    expect(new_rpt).not_to eq(rpt)
		end		
	end

	describe "#uma_rs_check_access" do
		it 'returns access status' do
		    response = @uma_command.uma_rs_check_access('/photo', 'GET')
		    expect(response['access']).to eq("granted").or eq("denied")
		end

		it 'raises error for invalid arguments' do
			# Empty path should raise error
			expect{ @uma_command.uma_rs_check_access('', 'GET') }.to raise_error(RuntimeError)

		    # Empty http_method should raise error
		    expect{ @uma_command.uma_rs_check_access('/photo', '') }.to raise_error(RuntimeError)

		    # raise error when http_method is wrong. should be one from ['GET', 'POST', 'PUT', 'DELETE']
		    expect{ @uma_command.uma_rs_check_access('/photo', 'DUMMY') }.to raise_error(RuntimeError)
		end
	end

	describe "#uma_rp_authorize_rpt" do
		it 'returns oxd_id' do
		    oxd_id = @uma_command.uma_rp_authorize_rpt
		    expect(oxd_id).not_to be_nil
		    expect(oxd_id).to eq(Oxd.config.oxd_id)
		end

		it 'raises error if response has error' do
			Oxd.config.ticket = 'ce2b9c5b-812b-40b6-98b4-28346c01db68'
		    expect{ @uma_command.uma_rp_authorize_rpt }.to raise_error(RuntimeError)
		end
	end

	describe "#uma_rp_get_gat" do
		it 'returns gat' do
			scopes = ["http://photoz.example.com/dev/actions/add","http://photoz.example.com/dev/actions/view","http://photoz.example.com/dev/actions/edit"]
		    gat = @uma_command.uma_rp_get_gat(scopes)
		end

		it 'raises error when scopes is not an array' do
		    # raise error when scopes is not an array
		    expect{ @uma_command.uma_rp_get_gat('scopes') }.to raise_error(RuntimeError)
		end
	end
end