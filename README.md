# Oxd Ruby

Ruby Client Library for the [Gluu oxD Server RP - v3.1.1](https://gluu.org/docs/oxd/3.1.1).

**oxdruby** is a thin wrapper around the communication protocol of oxD server. This can be used to access the OpenID connect & UMA Authorization end points of the Gluu Server via the oxD RP. This library provides the function calls required by a website to access user information from a OpenID Connect Provider (OP) by using the OxD as the Relying Party (RP).

## Using the Library in your website

> You are now on the `master` branch. If you want to use `oxd-ruby` for production use, switch to the branch of the matching version as the `oxd-server` you are installing.

[oxD RP](https://gluu.org/docs/oxd/3.1.1) has complete information about the Code Authorization flow and the various details about oxD RP configuration. This document provides only documentation about the oxd-ruby library.

### Prerequisites

* A valid OpenID Connect Provider (OP), like the Gluu Server or Google.
* An active installation of the oxd-server running on the same server as the client application.
* An active installation of the oxd-https-extension if oxd-https-extension connection is used. In this case, client applications can be on different servers but will be able to access oxd-https-extension.


### Installation

To install gem, add this line to your application's Gemfile:

```ruby
gem 'oxd-ruby', '~> 0.1.9'
```

Run bundle command to install it:

```bash
$ bundle install
```
#### Important Links

- See the [API docs](https://gluu.org/docs/oxd/3.1.1/libraries/ruby/) for in-depth information about the various functions and their parameters.
- See the code of a [sample Ruby on Rails app](https://github.com/GluuFederation/oxd-ruby/tree/master/demosite) built using oxd-ruby.

### Configuring

After you installed oxd-ruby, you need to run the generator command to generate the configuration file:

```bash
$ rails generate oxd:config
```

The generator will install `oxd_config.rb` initializer file in `config/initializers` directory which conatins all the global configuration options for oxd-ruby plguin. The generated configuration file looks like this: 

```ruby
config.oxd_host_ip = '127.0.0.1'
config.oxd_host_port = 8099
config.op_host = "https://your.openid.provider.com"
config.client_id = "<client_id of OpenId provider>"
config.client_secret = "<client_secret of OpenId provider>"
config.client_name = "Gluu Oxd Sample Client"
config.authorization_redirect_uri = "https://domain.example.com/callback"
config.logout_redirect_uri = "https://domain.example.com/callback2"
config.post_logout_redirect_uri = "https://domain.example.com/logout"
config.scope = ["openid","profile", "email", "uma_protection","uma_authorization"]
config.grant_types = []
config.application_type = "web"
config.response_types = ["code"]
config.acr_values = ["basic"]
config.client_jwks_uri = ""
config.client_token_endpoint_auth_method = ""
config.client_request_uris = []
config.contacts = ["example-email@gmail.com"]
config.client_logout_uris = ['https://domain.example.com/logout']
config.oxd_host = "https://127.0.0.1:8443" set if you are using oxd-https extension
config.connection_type = "local" if you are using oxd-server without oxd-https extension otherwise "web"
config.dynamic_registration	= true if the op_host supports dynamic registration otherwise 'false'
```
The following configuration must be set in config file before the gem can be used:

- config.oxd_host_ip
- config.oxd_host_port
- config.op_host
- config.authorization_redirect_uri
- config.client_id
- config.client_secret
- config.connection_type
- config.oxd_host

**Note :** client_id and client_secret must be set if your OpenID provider does not support dynamic registration, otherwise can be left blank.

## Usage

Add following snippet to your `application_controller.rb` file:

```ruby
require 'oxd-ruby'

before_filter :set_oxd_commands_instance
protected
	def set_oxd_commands_instance
		@oxd_command = Oxd::ClientOxdCommands.new
		@uma_command = Oxd::UMACommands.new
		@oxdConfig = @oxd_command.oxdConfig
	end
```

The `ClientOxdCommands` class of the library provides all the methods required for the website to communicate with the oxD RP through sockets. The `oxdConfig` method returns Oxd Configuration object.
The `UMACommands` class provides commands for UMA Resource Server(UMA RS) and UMA Requesting Party(UMA RP) protocol.

### Setup Client

In order to use an OpenID Connect Provider (OP) for login, you need to setup your client application at the OP. During setup oxd will dynamically register the OpenID Connect client and save its configuration. Upon successful setup a unique identifier will be issued by the oxd server by assigning a specific oxd id. Along with oxd Id oxd server will also return client Id and client secret. This client Id and client secret can be used for `get_client_token` method. The Setup Client method is a one time task to configure a client in the oxd server and OP.

**Note:** If your OpenID Connect Provider does not support dynamic registration (like Google), you will need to obtain a ClientID and Client Secret which can be set in `oxd_config.rb` initializer file.

```ruby
@oxd_command.setup_client
```

### Get Client Token

The `get_client_token` method is used to get a token which is sent as `protection_access_token` for other methods when the `protect_commands_with_access_token` is enabled in oxd-server.

> `get_client_token` command must be invoked to use following methods when the `protect_commands_with_access_token` is enabled in oxd-server.

```ruby
@oxd_command.get_client_token
```

### Website Registration

In order to use an OpenID Connect Provider (OP) for login, you need to register your client application at the OP. During registration oxd will dynamically register the OpenID Connect client and save its configuration. Upon successful registration a unique identifier will be issued by the oxd server. The Register Site method is a one time task to configure a client in the oxd server and OP.

**Note:** If your OpenID Connect Provider does not support dynamic registration (like Google), you will need to obtain a ClientID and Client Secret which can be set in `oxd_config.rb` initializer file.

```ruby
@oxd_command.register_site
```

### Get Authorization URL

The `get_authorization_url` method returns the OpenID Connect Provider authentication URL to which the client application must redirect the user to authorize the release of personal data. The response URL includes state value, which can be used to obtain tokens required for authentication. This state value is used 
to maintain state between the request and the callback.

```ruby
authorization_url = @oxd_command.get_authorization_url
```
Using the above url the website can redirect the user for authentication at the OpenId Provider. 

### Get access token

Upon successful login, the login result will return code and state. `get_tokens_by_code` uses code and state to retrieve token which can be used to access user claims.

```ruby
code = params[:code]
state = params[:state]
access_token = @oxd_command.get_tokens_by_code( code,state )
```
The values for code and state are parsed from the callback url query parameters.

### Get Access Token by Refresh Token

The `get_access_token_by_refresh_token` method is used to get a fresh access token and refresh token by using the refresh token which is obtained from `get_tokens_by_code` method.

```ruby
access_token = @oxd_command.get_access_token_by_refresh_token
```

### Get user claims

Once the user has been authenticated by the OpenID Connect Provider, the `get_user_info` method returns Claims (Like First Name, Last Name, emailId, etc.) about the authenticated end user. Claims (user information fields) made availble by the OpenId Provider can be fetched using the access token obtained above.

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

Once the required work is done the user can be logged out of the system. `get_logout_uri` method returns the OpenID Connect Provider logout url.

```ruby
logout_uri = @oxd_command.get_logout_uri(state, session_state)
```
You can then redirect the user to obtained url to perform logout.

## Using UMA commands

### UMA Protect resources

`uma_rs_protect` method is used for protecting resource with UMA Resource server. Resource server need to construct the command which will protect the resource. The command will contain api path, http methods (POST,GET, PUT) and scopes. Scopes can be mapped with authorization policy (uma_rpt_policies). If no authorization policy mapped, `uma_rs_check_access` method will always return access as granted.

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

### Get Requesting Party Token(RPT)
To gain access to protected resources at the UMA resource server, you must first obtain RPT.

**Method parameters:**

- claim_token: (Optional)
- claim_token_format: (Optional)
- pct: (Optional)
- rpt: (Optional)
- scope: (Optional)
- state: (Optional) state that is returned from uma_rp_get_claims_gathering_url method

```ruby
@uma_command.uma_rp_get_rpt
```

### UMA RP - Get Claims-Gathering URL

**Method parameters:**

- claims_redirect_uri: (Required)

```ruby
@uma_command.uma_rp_get_claims_gathering_url
```

## Logs
You can find `oxd-ruby.log` file in `rails_app_root/log` folder. It contains all the logs about oxd-server connections, commands/data sent to server, recieved response and all the errors and exceptions raised.

## Demo Site

The **demosite** folder contains a demo Ruby on Rails application which uses the `oxd-ruby` library to demonstrate the usage of the library. The deployment instrctions for the demo site can be found inside the demosite's README file.
