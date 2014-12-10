#!/usr/bin/ruby -w

=begin

GitHubStats script

Requirements:
Support OAuth tokens. Hardcoding the login data is fine. 
Have a list of repositories to watch. Hardcoding it is fine. 
Fetch the list of issues closed last week, or, with a flag, a different number of days. 
Discard issues not opened by one of GitHub users on a given list. Hardcoding the list is fine. 
Generate a report that lists each GitHub user who closed any issues in the time period, the number of issues closed, and the issues. 
Sort users by the number of issues closed. 
Send the report by email from a given address to a given address, using a descriptive subject line that includes the date. 

=end

require 'Octokit'
require 'optparse'
require 'rexml/document'

require_relative 'Configuration'

include REXML

#Read command line options
options = {}
options[:pathToConfigurationFile] = "./Config.xml"

OptionParser.new do |opts|
  opts.banner = "Usage: GitHubStats.rb [options]"

  opts.on("-c", "--configuration PATH", "Path to configuration file") do |pathToConf|
    options[:pathToConfigurationFile] = pathToConf
  end
end.parse!

p options
p ARGV

unless File.file?(options[:pathToConfigurationFile])
  puts "Error: Configuration file #{options[:pathToConfigurationFile]} does not exist."
  exit
end

#Read configuration file
xmlfile = File.new(options[:pathToConfigurationFile])
xmldoc = Document.new(xmlfile)
configuration = Configuration.new(xmldoc)

#Output configuration information
puts "Use authentication = #{configuration.UseAuthentication}"
puts "Path to netrc file = #{configuration.PathToNetrcFile}"
puts "Repositories = #{configuration.Repositories}"
puts "Since #{configuration.SinceDays} days"
puts "Users = #{configuration.Users}"
puts "Email results from #{configuration.EmailFrom} to #{configuration.EmailTo}"

client = Octokit
if configuration.UseAuthentication
  #TODO: Test this!!!
  client = Octokit::Client.new(:netrc => true, :netrc_file=>configuration.PathToNetrcFile)
  client.login
end

configuration.Repositories.each do |repository|
  puts "----- #{repository} -----"
  puts client.list_issues(repository, {:state => "closed"})
end
