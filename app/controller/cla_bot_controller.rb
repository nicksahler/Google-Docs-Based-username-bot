class ClaBotController < ApplicationController
  respond_to :html, :xml, :json
  
  @@git_username = "sirfoobar" #your username for github
  @@git_pass = "hunter2" #your password for github
  @@gdocs_username = "sirfoobar" #your username for google"
  @@gdocs_pass = "hunter4youwontguessitthistimeguys" #your password for google
  
  @@spreadsheet_id = "0adaas0das0d9asd0ja8d9a8wjdasdjaw" #The ID of the spreadsheet you want to read from
  
  @@username_column = "gsx:_clrrx" #The ID of the column containing usernames
  @@agree_column = "gsx:_ciyn3" #The ID of the column containing "I AGREE" for that username

  @@git_directory = "user/repo" #the directory for the repo of your 
  
  def create
    pl = params["cla_bot"]
    if pl["action"] == "opened" || pl["action"] == "reopened"#an opened or reopened pull request
      sender = pl["sender"]["login"]
      
      feed = client.get('https://spreadsheets.google.com/feeds/list/#{spreadsheet_id}/od7/private/values').to_xml
      
      signed = false
      feed.elements.each('entry') do |entry|
        if entry.elements[username_column].text.eql?(sender) && entry.elements[agree_column].text.eql?("I AGREE")
          signed = true
          break
        end
      end
      
      if signed
        body = {"body" => "You've signed the CLA, #{sender}. Thank you! This pull request is ready for review."}
      else
        body = {"body" => "Thanks for contributing this pull request! Could you please sign our CLA so we can review it?"}
      end
      #gh_client.post("/repos/#{directory_repo}/statuses/#{pl["pull_request"]["head"]["sha"]}", body)
      gh_client.post("/repos/#{directory_repo}/issues/#{pl["pull_request"]["number"]}/comments", body)
      
      begin
        pull_request_url = "http://github.com/#{git_directory}/pull/#{pl['number']}"
        message = "<a href=\"#{pull_request_url}\">Pull request number #{pl['number']}</a> was submitted"
        if signed
          message << ". The CLA was signed."
        else
          message << ", but the CLA was NOT signed."
        end
    end
    render nothing: true
  end
 
  private
 
  def client
    @client ||= begin
      c = GData::Client::Spreadsheets.new
      c.clientlogin(SiteSettings[@@gdocs_username], SiteSettings[@@gdocs_pass])
      c
    end
  end
 
  def gh_client
    @gh_client ||= Octokit::Client.new(login: SiteSettings[git_username], password: SiteSettings[git_pass])
  end
  end
end
