#!/usr/bin/ruby -w

=begin

GitHubStats script

Get issue statistics on GitHub repositories.

=end

require 'Octokit'
require 'optparse'
require 'rexml/document'
require 'mail'

require_relative 'Configuration'
require_relative 'String'
require_relative 'SimpleProgressbar'
require_relative 'Report'

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
          user = issue.user.rels[:self].get.data
          
          #Get only issues opened by specific users
          if configuration.Users.include? user.name
            issueObj = Issue.new(issue.title, issue.closed_by.rels[:self].get.data.name, issue.closed_at, user.name)
            issues << issueObj
          else
            if options[:debug]
              puts "Skipped issue with title '#{issue.title}'. User #{user.name} not in the specified list."
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

if options[:debug]
  puts issueList
end

#Build report
reportContents = Report.new(configuration.Repositories, issueList).to_s

if options[:debug]
  puts reportContents
end

Mail.deliver do
       to configuration.EmailTo
     from configuration.EmailFrom
  subject "[GitHubStats] #{Time.now}"
     body reportContents
end

puts "\nThe report has been sent to #{configuration.EmailTo}.".green
