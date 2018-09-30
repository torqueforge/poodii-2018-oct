puts
Dir.glob("bowling/test/**/*_test.rb") { |f|
  puts "running #{f}"
  require_relative("../#{f}") }