# OxdRuby gem main file
# @author Inderpal Singh
# @version 2.4.3

# require all files recursively from oxd_ruby dir
Dir[File.expand_path(File.join(File.dirname(File.absolute_path(__FILE__)), '/oxd_ruby')) + "/**/*.rb"].each do |file|
    require file
end

module OxdRuby
end