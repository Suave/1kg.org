class RbacBootstrapGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory File.join('app/controllers')
      m.directory File.join('app/models')
      m.directory File.join('app/views/auth')
      m.directory File.join('test/unit')
      m.directory File.join('test/functional')
      
      # create controller files
      m.file 'auth_controller.rb', 'app/controllers/auth_controller.rb'
      
      # create views
      %w( login logout ).each do |str|
        m.file "#{str}.rhtml", "app/views/auth/#{str}.rhtml"
      end
      
      # create controller tests
      m.file 'auth_controller_test.rb', 'test/functional/auth_controller_test.rb'
      
      # create models and tests
      %w( anonymous_user user role static_permission ).each do |str|
        m.file "#{str}.rb", "app/models/#{str}.rb"
        m.file "#{str}_test.rb", "test/unit/#{str}_test.rb"
      end
      
      # create fixtures
      %w( users roles static_permissions ).each do |str|
        m.file "#{str}.yml", "test/fixtures/#{str}.yml"
      end
      
      # create migrations
      m.migration_template 'add_rbac_schema.rb', 'db/migrate',
        :migration_file_name => "add_rbac_schema"
      m.migration_template 'insert_rbac_records.rb', 'db/migrate',
        :migration_file_name => "insert_rbac_records"

      # modify application_controller.rb
      file_contents = File.read('app/controllers/application.rb')
      
      if file_contents.match(/ActionController::Base/).nil? then
        file_contents << %Q{
# COULD NOT FIND substring "ActionController::Base"! You have to add the
# following line manually to your ApplicationController:
#
#   acts_as_current_user_container :anonymous_user => AnonymousUser
}
      else
        file_contents.gsub!(/ActionController::Base/, "\\0\n   acts_as_anonymous_user :anonymous_user => AnonymousUser")
      end
      
      File.open('app/controllers/application.rb', 'w') do |f|
        f.write(file_contents)
      end
    end
  end
end
