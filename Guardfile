# More info at https://github.com/guard/guard#readme
#!/usr/bin/env/ ruby
    #allow sublime text to color syntax by default

require 'active_support/inflector'

# guard 'livereload' do
#   watch(%r{app/views/.+\.(erb|haml|slim)$})
#   watch(%r{app/helpers/.+\.rb})
#   watch(%r{public/.+\.(css|js|html)})
#   watch(%r{config/locales/.+\.yml})
#   # Rails Assets Pipeline
#   watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html))).*}) { |m| "/assets/#{m[3]}" }
# end

# files here will automatically reload spork if changed
guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' },
               :rspec_env    => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch('config/environments/test.rb')
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch('test/test_helper.rb') { :test_unit }
  watch(%r{features/support/}) { :cucumber }
  watch(%r{^spec/support/.+\.rb$})              #anything in support folder
  watch('spec/factories.rb')                    #FactoryGirl factories
end

guard 'rspec', all_on_start: false, all_after_pass: false, cli: '--drb' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  # Rails example
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }

  # Capybara features specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/features/#{m[1]}_spec.rb" }

  # Custom Rails Tutorial specs
  watch(%r{^app/controllers/(.+)_(controller)\.rb$}) do |m|
    ["spec/routing/#{m[1]}_routing_spec.rb",
     "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb",
     "spec/acceptance/#{m[1]}_spec.rb",
     (m[1][/_pages/] ? "spec/requests/#{m[1]}_spec.rb" :
                       "spec/requests/#{m[1].singularize}_pages_spec.rb")]
  end
  watch(%r{^app/views/(.+)/}) do |m|
    (m[1][/_pages/] ? "spec/requests/#{m[1]}_spec.rb" :
                      "spec/requests/#{m[1].singularize}_pages_spec.rb")
  end
  watch(%r{^app/controllers/sessions_controller\.rb$}) do |m|
    "spec/requests/authentication_pages_spec.rb"
  end
end

