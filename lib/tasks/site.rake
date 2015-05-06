desc "Cleans up the build directory"
task :clean do
  unless system 'rm -rf build'
    fail "Couldn't clean up directory"
  end
end

desc "Runs the Middleman server"
task :server do
  system 'middleman server'
end

desc "Builds the Middleman site"
task :build do
  unless system 'middleman build'
    fail "Middleman build failed."
  end
end

desc "Set STAGE to staging"
task "set_staging_env" do
  ENV['STAGE'] = 'staging'
end

desc "Set STAGE to qa"
task "set_qa_env" do
  ENV['STAGE'] = 'qa'
end

desc "Set STAGE to production"
task "set_production_env" do
  ENV['STAGE'] = 'production'
end

namespace :deploy do
  desc "Deploy static site to staging"
  task :staging => [:set_staging_env, :clean, :build, 'deploy:sync'] do
    notify(":shipit: #{ user } deployed #{repo_name} to staging")
  end

  desc "Deploy static site to qa"
  task :qa => [:set_qa_env, :clean, :build, 'deploy:sync'] do
    notify(":shipit: #{ user } deployed #{repo_name} to qa")
  end

  desc "Confirm deploy static site to production"
  task :production_confirm do
    confirmation_string = "deploy to production"
    puts "Production deploy initiated!"
    puts "Please type '#{confirmation_string}' then press return to confirm."
    unless STDIN.gets.strip == confirmation_string
      fail "Production deploy canceled"
    end
  end

  desc "Deploy static site to production"
  task :production => [:production_confirm, :set_production_env, :clean, :build, 'deploy:sync'] do
    notify(":shipit: #{ user } deployed #{repo_name} to production")
  end

  desc "Syncs with S3"
  task :sync do
    retries = 5
    while retries > 0
      if system 'middleman s3_sync'
        puts "Sync to stage #{ENV['STAGE']} completed OK."
        break
      else
        retries -= 1
        puts "Sync error while syncing to stage: #{ENV['STAGE']}."
      end
    end
  end

  def notify(message)
    require 'flowdock'

    # create a new Flow object with target flow's api token and sender information
    flow = Flowdock::Flow.new(
              api_token: "7e1c8271ffb6351a6405237d73b83383",
              source: "Rake deployment",
              project: app_name,
              from: {name: "Mr. Roboto", address: "dojo4@dojo4.com"}
           )

    # send message to the flow
    flow.push_to_team_inbox(
      format: "html", 
      subject: "#{ app_name } deployed to #{ ENV['STAGE'] }",
      content: message, 
      tags: ["deploy", app_name]
    )
  rescue LoadError
    warn "gem install flowdock # to notify dojo4 flowdock..."
  end

  def repo_name
    @repo_name ||= `git remote -v` =~ %r{/(.+)(\.git)? \(fetch\)} && $1.split('/').last
  end

  def app_name
    repo_name.sub('.git', '')
  end

  def user
    ENV['USER']
  end

  def root_dir
    @root_dir ||= Rake.application.original_dir
  end
end

namespace :test do
  desc "tests notifying flowdock of a message"
  task :notify do
    notify("this is a test")
  end
end
