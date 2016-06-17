require 'spec_helper'

describe Oxd do
	it 'has a version number' do
		expect(Oxd::VERSION).not_to be nil
	end

	it 'has valid configuration' do
		expect(Oxd.config).not_to be nil
	end

	it 'configuration has valid authorization_redirect_uri' do
		expect(Oxd.config.authorization_redirect_uri).not_to be_nil
	end

	it 'configuration has valid IP Address' do
		expect{ IPAddr.new(Oxd.config.oxd_host_ip) }.not_to raise_error
	end

	it 'configuration has valid port number' do
		expect(Oxd.config.oxd_host_port).to eq(8099)
	end
end
