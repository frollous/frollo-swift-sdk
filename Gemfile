# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "fastlane"
gem 'carthage_cache'
gem "jazzy"
gem 'xcov'

# Hack for multi destination simulators
gem "xcpretty", :git => "https://github.com/technology-ebay-de/xcpretty", :ref => "2b681274dbdef611374d70118cdf4170fae3d55b"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
