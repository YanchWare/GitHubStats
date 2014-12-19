=begin
Class representing an user object used in order to hold report data
=end
class User
  def initialize(name, firstIssue)
    @userName = name
    @issuesSolved = [firstIssue]
  end
  
  def IssuesSolved
    @issuesSolved 
  end
  
  def UserName
    @userName 
  end  
  
  def eql?(other_object)
    (self.class.equal?other_object.class and
    self.UserName == other_object.UserName and
    self.IssuesSolved == other_object.IssuesSolved) or 
    (self.UserName == other_object)
  end
  
  alias == eql?
  
end

=begin
Class representing an issue object used in order to hold report data
=end
class Issue
  def initialize(title, closedBy, closedAt, openedBy)
    @title = title
    @closedBy = closedBy
    @closedAt = closedAt
    @openedBy = openedBy
  end
  
  def Title
    @title
  end

  def ClosedBy
    @closedBy
  end

  def ClosedAt
    @closedAt
  end
  
  def OpenedBy
    @openedBy
  end
  
end

=begin
Class implementing report behavior
=end
class Report
  def initialize(repos, issues)
    @usersByUserNames = {}
    @issuesClosed = issues
    @repositories = repos
    
    @issuesClosed.each do | issue |
      userFound = @usersByUserNames[issue.ClosedBy]
      if userFound
        userFound.IssuesSolved << issue
      else
        @usersByUserNames[issue.ClosedBy] = User.new(issue.ClosedBy, issue)
      end
    end    
  end
  
  def to_s
    retS = "\n==========[GitHubStats Report]==========\nAnalyzed #{@repositories.length} repositories:\n"

    @repositories.each do |repository|
      retS += repository + "\n"
    end

    retS += "\nFound a total of #{@issuesClosed.length} issues.\n" +    
    "\n================[Users]================\nUsers found ordered by number of issues solved:\n\n"
        
    @usersByUserNames.sort_by{|k,v| v.IssuesSolved.length}.reverse.each do |userName, userObj|
      retS += "----------- #{userName}: #{userObj.IssuesSolved.length} issues solved ----------- \n"
      userObj.IssuesSolved.each do |issue|
        retS += "Title: #{issue.Title}\nOpened by #{issue.OpenedBy} and closed by #{issue.ClosedBy} at #{issue.ClosedAt}\n\n"
      end
    end
    
    retS
    
  end
  
end