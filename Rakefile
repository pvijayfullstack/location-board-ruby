require "rspec/core/rake_task"

desc "Run those specs"
task :spec do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w{--colour --format progress}
    t.pattern = 'spec/*_spec.rb'
  end
end

desc "Deploy to Heroku"
task :deploy do
  system "git add -f user_data.rb && git commit -m 'Adding user_data.rb'"
  system "git push heroku master -f"
  system "git reset HEAD^"
  system "git reflog expire --expire=now --all"
end