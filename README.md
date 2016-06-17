# Oxd Ruby
[![Gem Version](https://badge.fury.io/rb/oxd-ruby.png)](https://badge.fury.io/rb/oxd-ruby)

Ruby Client Library for the [Gluu oxD Server RP - v2.4.3 & 2.4.4](http://ox.gluu.org/doku.php?id=oxd:rp).

**oxdruby** is a thin wrapper around the communication protocol of oxD server. This can be used to access the OpenID connect & UMA Authorization end points of the Gluu Server via the oxD RP. This library provides the function calls required by a website to access user information from a OpenID Connect Provider (OP) by using the OxD as the Relying Party (RP).

## Using the Library in your website

> You are now on the `master` branch. If you want to use `oxd-ruby` for production use, switch to the branch of the matching version as the `oxd-server` you are installing

[oxD RP](http://ox.gluu.org/doku.php?id=oxd:rp) has complete information about the Code Authorization flow and the various details about oxD RP configuration. This document provides only documentation about the oxd-ruby library.

### Prerequisites

* Install `gluu-oxd-server`
Oxd-server needs to be running on your machine to connect with OP.

### Installation

To install gem, add this line to your application's Gemfile:

```ruby
gem 'oxd-ruby', '~> 0.1.1'
```

Run bundle command to install it:
```bash
$ bundle install
```

### Configuring
After you installed oxd-ruby, you need to run the generator command:
```bash
$ rails generate oxd:config
```

The generator will install `oxd_config.rb` initializer file in `config/initializers` directory which conatins ALL of Oxd-Ruby's global configuration options.
You must set values for `config.oxd_host_ip`, `config.oxd_host_port`, `config.authorization_redirect_uri` in config file.
Change these settings according to your website otherwise your website will not be able to communicate properly with the Oxd Server.

## Usage

Add these lines to your application_controller.rb file:
```ruby
require 'oxd-ruby'

before_filter :set_oxd_commands_instance
protected
	def set_oxd_commands_instance
		@oxd_command = Oxd::ClientOxdCommands.new
	end
```

The `ClientOxdCommands` class of the library provides all the methods required for the website to communicate with the oxD RP through sockets.

### Website Registration

The website can be registered with the OP using the `@oxd_command.register_site` call.

### Get Authorization URL

The first step is to generate an authorization url which the user can visit to authorize your application to use the information from the OP.

```ruby
authorization_url = @oxd_command.get_authorization_url
```
Using the above url the website can redirect the user for authentication at the OP.

### Get access token

The website needs to parse the information from the callback url and pass it on to get the access token for fetching user information.

```ruby
code = params[:code]
state = params[:state]
scopes = params[:scope].split("+")
access_token = @oxd_command.get_tokens_by_code( code, scopes, state )
```
The values for code, scopes and state are parsed from the callback url query parameters.

### Get user claims

Claims (user information fields) made availble by the OP can be fetched using the access token obtained above.

```ruby
user = @oxd_command.get_user_info(access_token)
```

### Using the claims

Once the user data is obtained, the various claims supported by the OP can be used as required.
```ruby
<% user.each do |field,value| %>
	<%= "#{field} : #{value}" %>
<% end %>
```
The availability of various claims are completely dependent on the OP.

### Logging out

Once the required work is done the user can be logged out of the system.
```ruby
logout_uri = @oxd_command.get_logout_uri(access_token, state, session_state)
```
You can then redirect the user to obtained url to perform logout.

### Logs
You can find `oxd-ruby.log` file in `rails_app_root/log` folder. It contains all the logs about oxd-server connections, commands/data sent to server, recieved response and all the errors and exceptions raised.

## Demo Site

The **demosite** folder contains a demo Ruby on Rails application which uses the `oxd-ruby` library to demonstrate the usage of the library. The deployment instrctions for the demo site can be found inside the demosite's README file.
