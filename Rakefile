#!/usr/bin/env ruby
# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ydim/html/version'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :spec => :clean

require 'rake/clean'
CLEAN.include FileList['pkg/*.gem']
