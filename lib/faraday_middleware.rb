faraday_middleware_files = Dir[File.join(File.dirname(__FILE__), "/faraday/**/*.rb")].sort
faraday_middleware_files.each do |file|
  require file
end
