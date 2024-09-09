#!/usr/bin/env ruby

require 'uri'
require 'net/http'
require 'json'

def check_ref(ref)
  return "" if ref.nil?

  " " + ref
end

def check_type(type, event)
  case type
  when 'PushEvent' then "Pushed #{event[:payload][:size]} commit(s) to #{event[:repo][:name]}"
  when 'CreateEvent' then "Created #{event[:payload][:ref_type]}#{check_ref(event[:payload][:ref])} in #{event[:repo][:name]}"
  when 'WatchEvent' then "Stared the repo #{event[:repo][:name]}"
  when 'PublicEvent' then "Changed #{event[:repo][:name]} to public"
  when 'IssueCommentEvent' then "Reviewed a pull request in #{event[:repo][:name]}"
  else "#{type} in #{event[:repo][:name]}"
  end
end

def get_activities(events)
  events.map do |event|
    "- #{check_type(event[:type], event)}"
  end
end

def main
  if ARGV.empty?
    puts 'Usage: ./github_activity_cli.rb <github-username>'
    exit
  end

  username = ARGV[0]
  uri = URI("https://api.github.com/users/#{username}/events")
  res = Net::HTTP.get_response(uri)

  raise(StandardError, "The user is not found") if res.code == "404"

  raise(StandardError, "An error occurred while fetching") if res.code != "200"

  events = JSON.parse(res.body, { :symbolize_names => true })

  get_activities(events).each { |activity| puts activity }
rescue StandardError => err
  puts err.full_message
end


main if __FILE__ == $PROGRAM_NAME
