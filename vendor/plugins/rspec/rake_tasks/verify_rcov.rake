require 'rake'
require 'spec/rake/verify_rcov'

RCov::VerifyTask.new(:verify_rcov => :spec) do |t|
<<<<<<< HEAD:vendor/plugins/rspec/rake_tasks/verify_rcov.rake
<<<<<<< HEAD:vendor/plugins/rspec/rake_tasks/verify_rcov.rake
  t.threshold = 100.0
=======
  t.threshold = 100.0 # Make sure you have rcov 0.7 or higher!
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/rake_tasks/verify_rcov.rake
=======
  t.threshold = 100.0 # Make sure you have rcov 0.7 or higher!
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/rake_tasks/verify_rcov.rake
  t.index_html = 'coverage/index.html'
end
