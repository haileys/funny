$: << File.expand_path("../lib", __FILE__)
require "funny"

Funny.parse(ARGF.read).each do |stmt|
  puts stmt.inspect
  puts 
end