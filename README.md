GitHubStats
===========

Introduction
--------------

The GitHubStats is a simple script used in order to get statistics on closed issues related to some well defined repositories. The script need to be configured before use. At completition the script emails the report to the specified recipient.

Dependencies
--------------
This script depends on the following Ruby gems:

mail
Octokit
netrc

Configuration
--------------

The script needs to be correctly configured using a xml configuration file.
An simple example of that can be found in this repository.


Run
--------------
You can run the script by typing on the command line the following command:
<code>ruby GitHubStats.rb</code>

You can define the location of the configuration script through command line arguments as shown below:
<code>ruby GitHubStats.rb -c ./config.xml</code>

Moreover you can activate debugging information as follows:
<code>ruby GitHubStats.rb -d</code>


Authentication
--------------
Authentication against GitHub if needed is performed through the use of a netrc configuration file.
Please read more [here][1]

Email report
--------------
In this repository it has been created a sample using gmail SMTP servers in order to email the report to the required recipient. You can find documentation on line on how to support local mail servers or other providers.
The example used here has been taken from [here][2]

[1]:https://rubygems.org/gems/netrc
[2]:http://lindsaar.net/2010/3/15/how_to_use_mail_and_actionmailer_3_with_gmail_smtp