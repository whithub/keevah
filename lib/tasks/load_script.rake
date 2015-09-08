require "load_script/session"
require 'capybara/poltergeist'

namespace :load_script do
  desc "Run a load testing script against the app. Accepts 'HOST' as an ENV argument. Defaults to 'localhost:3000'."
  task :run => :environment do
    if `which phantomjs`.empty?
      raise "PhantomJS not found. Make sure you have it installed. Try: 'brew install phantomjs'"
    end
    LoadScript::Session.new(ARGV[1]).run
  end


  desc "Simulate load against Optimized application"
  task :run => :environment do
    4.times.map { Thread.new { browse } }.map(&:join)
    # 4.times.map { Thread.new { post } }.map(&:join)
  end

  def browse
    session = Capybara::Session.new(:poltergeist)
    loop do
      session.visit('https://dry-reaches-4292.herokuapp.com/')
      session.all("li.article a").sample.click
    end
  end
end

# TODO: Add concurrency factor:
#if __FILE__ == $0
  #1.times.map do
    #Thread.new do
      #if ARGV[0] #host
        #Session.new(ARGV[0]).run
      #else
        #Session.new.run
      #end
    #end
  #end.map(&:join)
#end
