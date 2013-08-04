# -*- encoding : utf-8 -*-
require File.join(File.dirname(__FILE__), "story_helper")

Story "Anonymous signup an account", %{
  As an anonymous visitor
  I want to signup an account
}, :type => RailsStory do
  
  Scenario "visit index and click signup" do 
    When "visiting home page" do
      get '/'
    end
    
    Then "user should see home page" do
      response.should render_template('users/new')
    end
  end
end
