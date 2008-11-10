<<<<<<< HEAD:vendor/plugins/rspec/stories/mock_framework_integration/use_flexmock.story
<<<<<<< HEAD:vendor/plugins/rspec/stories/mock_framework_integration/use_flexmock.story
Story: Getting correct output with flexmock
=======
Story: Getting correct output
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/stories/mock_framework_integration/use_flexmock.story
=======
Story: Getting correct output
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/stories/mock_framework_integration/use_flexmock.story

  As an RSpec user who prefers flexmock
  I want to be able to use flexmock without rspec mocks interfering

  Scenario: Mock with flexmock
    Given the file spec/spec_with_flexmock.rb
    When I run it with the ruby interpreter
    Then the exit code should be 0