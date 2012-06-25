$: << File.expand_path("../lib", __FILE__)
require "funny"

puts Funny.compile ARGF.read