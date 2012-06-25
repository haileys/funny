$: << File.expand_path("../lib", __FILE__)
require "funny"

puts (eval Funny.compile ARGF.read)[->n { n + 1 }][0]