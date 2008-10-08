Story: Create a new account
  As a user,
  I want to signup an account,
  So that I can use more features of the site

  Scenario: User fill signup form to create account
    Given a email 'suave@1kg.org'
    And a name 'Suave'
    And a password '123456'
    And there is no user with email 'suave@1kg.org'
    
    When the user create an account with email, name and password
    
    Then there should be a user named 'Suave'
    And should redirect to the activation page with notice info 'An activation email has been send to your mailbox, please check & activate your account'
  
  Scenario: title
    Given context
    When event
    Then outcome
  
