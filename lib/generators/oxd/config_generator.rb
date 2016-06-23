module Oxd

  # Generator module for oxd_config.rb
  module Generators

    # class to generate oxd config file through "rails generate" command
    # @example
    #   rails generate oxd:config
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      desc <<DESC
      Description:
          Copies Oxd configuration file to your application's initializer directory.
DESC
      # copies oxd_config.rb template to 'config/initializers/oxd_config.rb'
      def copy_config_file
        template 'oxd_config.rb', 'config/initializers/oxd_config.rb'
      end
    end
  end
end
