=begin

Class representing a configuration object after deserializing the configuration file

=end

class Configuration

  def initialize(xmlDoc)
    #Authentication
    authenticationNode = XPath.first(xmlDoc, "Configuration/Authentication")
    @useAuthentication = XPath.first(authenticationNode, "@active").to_s == "true"
    if @useAuthentication
      @pathToNetrcFile = XPath.first(authenticationNode, "@pathToNetrcFile").to_s
      if not @pathToNetrcFile or not File.file?(@pathToNetrcFile)
        @useAuthentication = false
      end 
    end
    
    #Repositories
    @repositories = XPath.match(xmlDoc, "Configuration/Repositories/Repository/@src").map {|x| x.to_s }

    #Since
    @sinceDays = XPath.first(xmlDoc, "Configuration/Since/@days").to_s.to_i

    #Users
    @users = XPath.match(xmlDoc, "Configuration/Users/User/@name").map {|x| x.to_s }

    #Email settings
    emailSettingsNode = XPath.first(xmlDoc, "Configuration/EmailSettings")
    @emailFrom = XPath.first(emailSettingsNode, "@from").to_s
    @emailTo = XPath.first(emailSettingsNode, "@to").to_s
    
    #Setting standards mail options
    mailOptions = { :address              => XPath.first(emailSettingsNode, "@serverAddress").to_s,
                    :port                 => XPath.first(emailSettingsNode, "@serverPort").to_s.to_i,
                    :domain               => XPath.first(emailSettingsNode, "@domain").to_s,
                    :user_name            => XPath.first(emailSettingsNode, "@userName").to_s,
                    :password             => XPath.first(emailSettingsNode, "@password").to_s,
                    :authentication       => XPath.first(emailSettingsNode, "@authentication").to_s,
                    :enable_starttls_auto => XPath.first(emailSettingsNode, "@enable_starttls_auto").to_s == "true"
                  }
    puts mailOptions
    Mail.defaults do
      delivery_method :smtp, mailOptions
    end
    
    
  end
  
  def UseAuthentication
    @useAuthentication
  end
  
  def PathToNetrcFile
    @pathToNetrcFile
  end

  def Repositories
    @repositories
  end

  def SinceDays
    @sinceDays
  end

  def Users
    @users
  end

  def EmailFrom
    @emailFrom
  end
  
  def EmailTo
    @emailTo
  end
  
end