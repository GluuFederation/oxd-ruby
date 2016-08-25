# Change Log
All notable changes to this project will be documented in this file.

## [0.1.6] - 2016-08-25
### Added
- `client_secret_expires_at` parameter in `update_registration_site` command
- `prompt : login` parameter in `get_authorization_url` command
- `client_id` and `client_secret` parameter in `register_site` command

### Removed
- `config.redirect_uris` parameter from configuration
- `redirect_uris` parameter from `register_site` and `update_registr_site` commands
- `state` and `scopes` parameters from `get_tokens_by_code` command

## [0.1.5] - 2016-07-20
### Added
- support for https protocol

## [0.1.4] - 2016-06-25
### Added
- support for oxd-server 2.4.4
- support for UMA
- `config.op_host` parameter in configuration
- added scopes "uma_protection","uma_authorization"