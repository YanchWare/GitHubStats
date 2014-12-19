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

Ouput sample
--------------
```
==========[GitHubStats Report]==========
Analyzed 3 repositories:
okamstudio/godot
Caliburn-Micro/Caliburn.Micro
octokit/octokit.rb

Found a total of 4 issues.

================[Users]================
Users found ordered by number of issues solved:

----------- Juan Linietsky: 2 issues solved ----------- 
Title: Pr-tween-fix
Opened by Saniko and closed by Juan Linietsky at 2014-12-19 13:59:26 UTC

Title: Fix crash when gd-script _init fail
Opened by Saniko and closed by Juan Linietsky at 2014-12-18 04:54:50 UTC

----------- Ribhararnus Pracutiar: 1 issues solved ----------- 
Title: Can I take picture with phone camera?
Opened by Ribhararnus Pracutiar and closed by Ribhararnus Pracutiar at 2014-12-13 15:48:41 UTC

----------- Luiz Eduardo Kowalski: 1 issues solved ----------- 
Title: Can't get private organizations when octokit is authenticated
Opened by Luiz Eduardo Kowalski and closed by Luiz Eduardo Kowalski at 2014-12-16 16:49:19 UTC
```

[1]:https://rubygems.org/gems/netrc
[2]:http://lindsaar.net/2010/3/15/how_to_use_mail_and_actionmailer_3_with_gmail_smtp