namespace :travis do
  desc 'Runs rspec specs and jasmine specs on travis'
  task :run_specs do
    ['bundle exec rspec spec', 'npm test', 'npm run coveralls', 'npm run test:ci'].each do |cmd|
      puts "Starting to run #{cmd}..."
      system("export DISPLAY=:99.0 && #{cmd}")
      raise "#{cmd} failed!" unless $CHILD_STATUS.exitstatus.zero?
    end
  end
end

task travis: 'travis:run_specs'
