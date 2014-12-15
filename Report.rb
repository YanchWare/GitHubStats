=begin
Class representing an user object used in order to hold report data
=end
class User
  def initialize(name)
    @userName = name
    @issuesSolved = 1
  end
  
  def IssuesSolved
    @issuesSolved 
  end

  def IssuesSolved=(newIssueSolved)
    @issuesSolved = newIssueSolved
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
  def initialize(title, closedBy, closedAt)
    @title = title
    @closedBy = closedBy
    @closedAt = closedAt
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
        userFound.IssuesSolved += 1
      else
        @usersByUserNames[issue.ClosedBy] = User.new(issue.ClosedBy)
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
    
    @usersByUserNames.sort_by{|k,v| v.IssuesSolved}
    
    @usersByUserNames.sort_by{|k,v| v.IssuesSolved}.reverse.each do |userName, userObj|
      retS += "#{userName}: #{userObj.IssuesSolved} issues solved\n"
    end

    retS += "\n===============[Issues]================\nIssues found:\n\n"
    
    @issuesClosed.each do |issue|
      retS += "Title: #{issue.Title}\nClosed by #{issue.ClosedBy} at #{issue.ClosedAt}\n\n"
    end
    
    retS
    
  end
  
end