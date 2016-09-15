# Oxd Ruby
[![Gem Version](https://badge.fury.io/rb/oxd-ruby.png)](https://badge.fury.io/rb/oxd-ruby)

Ruby Client Library for the [Gluu oxD Server RP - v2.4.4](https://www.gluu.org/docs-oxd/).

**oxdruby** is a thin wrapper around the communication protocol of oxD server. This can be used to access the OpenID connect & UMA Authorization end points of the Gluu Server via the oxD RP. This library provides the function calls required by a website to access user information from a OpenID Connect Provider (OP) by using the OxD as the Relying Party (RP).

## Using the Library in your website

> You are now on the `master` branch. If you want to use `oxd-ruby` for production use, switch to the branch of the matching version as the `oxd-server` you are installing.

[oxD RP](https://www.gluu.org/docs-oxd/) has complete information about the Code Authorization flow and the various details about oxD RP configuration. This document provides only documentation about the oxd-ruby library.

### Prerequisites

* Install `gluu-oxd-server`

Oxd-server needs to be running on your machine to connect with OP.

* Enable SSL on your website otherwise this library will not work.

### Installation

To install gem, add this line to your application's Gemfile:

```ruby
gem 'oxd-ruby', '~> 0.1.6'
```

Run bundle command to install it:

```bash
$ bundle install
```

### Configuring
After you installed oxd-ruby, you need to run the generator command to generate the configuration file:

```bash
$ rails generate oxd:config
```

The generator will install `oxd_config.rb` initializer file in `config/initializers` directory which conatins all the global configuration options for oxd-ruby plguin.
The following configurations must be set in config file before the plugin can be used.

1. config.oxd_host_ip
2. config.oxd_host_port
3. config.op_host
4. config.authorization_redirect_uri


## Usage

Add following snippet to your `application_controller.rb` file:

```ruby
require 'oxd-ruby'

before_filter :set_oxd_commands_instance
protected
	def set_oxd_commands_instance
		@oxd_command = Oxd::ClientOxdCommands.new
		@uma_command = Oxd::UMACommands.new
	end
```

The `ClientOxdCommands` class of the library provides all the methods required for the website to communicate with the oxD RP through sockets.
The `UMACommands` class provides commands for UMA Resource Server(UMA RS) and UMA Requesting Party(UMA RP) protocol.

### Website Registration

The website can be registered with the OpenId Provider using the `@oxd_command.register_site` call.

### Get Authorization URL

The first step is to generate an authorization url which the user can visit to authorize your application to use the information from the OpenId Provider.

```ruby
authorization_url = @oxd_command.get_authorization_url
```
Using the above url the website can redirect the user for authentication at the OpenId Provider.

### Get access token

The website needs to parse the information from the callback url and pass it on to get the access token for fetching user information.

```ruby
code = params[:code]
access_token = @oxd_command.get_tokens_by_code( code )
```
The values for code are parsed from the callback url query parameters.

### Get user claims

Claims (user information fields) made availble by the OpenId Provider can be fetched using the access token obtained above.

```ruby
user = @oxd_command.get_user_info(access_token)
```

### Using the claims

Once the user data is obtained, the various claims supported by the OpenId Provider can be used as required.

```ruby
<% user.each do |field,value| %>
	<%= "#{field} : #{value}" %>
<% end %>
```
The availability of various claims are completely dependent on the OpenId Provider.

### Logging out

Once the required work is done the user can be logged out of the system.

```ruby
logout_uri = @oxd_command.get_logout_uri(access_token, state, session_state)
```
You can then redirect the user to obtained url to perform logout.

## Using UMA commands

### UMA Protect resources

To protect resources with UMA Resource server, you need to add resources to library using `uma_add_resource(path, *conditions)` method. Then you can call following method to register resources for protection with UMA RS.

```ruby
@uma_command.uma_add_resource(path, *conditions)
@uma_command.uma_rs_protect
```

### UMA Check access for a particular resource
To check wether you have access to a particular resource on UMA Resource Sevrer or not, use following method:

```ruby
@uma_command.uma_rs_check_access(path, http_method)
```
You must first get RPT before calling this method.

### Get Requesting Party Token(RPT)
To gain access to protected resources at the UMA resource server, you must first obtain RPT.

```ruby
@uma_command.uma_rp_get_rpt(force_new)
```

### Authorize RPT
You must first call `uma_rp_get_rpt` and `uma_rs_check_access` methods before authorizing RPT. If you have already obtained the RPT, use `uma_rp_authorize_rpt` method provided by oxd-ruby library to authorize it.

```ruby
@uma_command.uma_rp_authorize_rpt
```

### Get Gluu Access Token(GAT)
To obtain GAT(Gluu Access Token) call following method with scopes as parameter.

```ruby
@uma_command.uma_rp_get_gat(scopes)
```

## Logs
You can find `oxd-ruby.log` file in `rails_app_root/log` folder. It contains all the logs about oxd-server connections, commands/data sent to server, recieved response and all the errors and exceptions raised.

## Demo Site

The **demosite** folder contains a demo Ruby on Rails application which uses the `oxd-ruby` library to demonstrate the usage of the library. The deployment instrctions for the demo site can be found inside the demosite's README file.
