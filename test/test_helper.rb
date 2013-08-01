require 'rubygems'
require 'minitest/autorun'
require 'minitest/spec'
$:.unshift 'lib'
require 'lotus/view'
Lotus::View.root = Pathname.new __dir__ + '/fixtures/templates'
require 'fixtures'
Lotus::View.load!
