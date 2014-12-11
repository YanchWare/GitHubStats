#!/usr/bin/ruby -w

=begin

GitHubStats script

Requirements:
DONE: Support OAuth tokens. Hardcoding the login data is fine.
DONE: Have a list of repositories to watch. Hardcoding it is fine. 
DONE: Fetch the list of issues closed last week, or, with a flag, a different number of days. 
DONE: Discard issues not opened by one of GitHub users on a given list. Hardcoding the list is fine. 
Generate a report that lists each GitHub user who closed any issues in the time period, the number of issues closed, and the issues. 
Sort users by the number of issues closed. 
Send the report by email from a given address to a given address, using a descriptive subject line that includes the date. 
Create brief README

=end

require 'Octokit'
require 'optparse'
require 'rexml/document'

require_relative 'Configuration'
require_relative 'String'
require_relative 'SimpleProgressbar'

include REXML

#Read command line options
options = {}
options[:pathToConfigurationFile] = "./Config.xml"
options[:debug] = false

OptionParser.new do |opts|
  opts.banner = "Usage: GitHubStats.rb [options]"

  opts.on("-c", "--configuration PATH", "Path to configuration file") do |pathToConf|
    options[:pathToConfigurationFile] = pathToConf
  end

  opts.on("-d", "--debug", "Path to configuration file") do |debug|
    options[:debug] = debug
  end

end.parse!

unless File.file?(options[:pathToConfigurationFile])
  puts "Error: Configuration file #{options[:pathToConfigurationFile]} does not exist."
  exit
end

#Read configuration file
xmlfile = File.new(options[:pathToConfigurationFile])
xmldoc = Document.new(xmlfile)
configuration = Configuration.new(xmldoc)

if options[:debug]
  #Output configuration information
  puts "Use authentication = #{configuration.UseAuthentication}"
  puts "Path to netrc file = #{configuration.PathToNetrcFile}"
  puts "Repositories = #{configuration.Repositories}"
  puts "Since #{configuration.SinceDays} days"
  puts "Users = #{configuration.Users}"
  puts "Email results from #{configuration.EmailFrom} to #{configuration.EmailTo}"
end

client = Octokit
if configuration.UseAuthentication
  #TODO: Test this!!!
  client = Octokit::Client.new(:netrc => true, :netrc_file => configuration.PathToNetrcFile)
  client.login
end

timeRange = (Time.now - (configuration.SinceDays*24*60*60))..Time.now

issueList = [].tap do |issues|
  configuration.Repositories.each do |repository|

    listIssueRet = client.list_issues(repository, {:state => "closed"})
    i = 0
    SimpleProgressbar.new.show("Scanning #{repository}".blue) do
      listIssueRet.each do |item|
        issue = item.rels[:self].get.data
        
        #Get only the issues closed in the given time frame
        if timeRange.cover?(issue.closed_at)
          user = issue.closed_by.rels[:self].get.data
          
          #Get only issues closed by specific users
          if configuration.Users.include? user.name
            issueObj = {
              title: issue.title,
              closedBy: user.name,
              closedAt: issue.closed_at
            }
            issues << issueObj
          else
            if options[:debug]
              puts "Skipped issue with title '#{issue.title}'. User not in the specified list."
            end            
          end
        else
          if options[:debug]
            puts "Skipped issue. Not closed in the specified time period. Exiting loop"
          end
          break
        end
        #Update progressbar
        progress (i*100)/listIssueRet.length
        i+=1
      end
      #Update progressbar
      progress 100
    end
  end
end

puts "Found #{issueList.length} interesting issues in the specified repositories."

if options[:debug]
  puts issueList
end