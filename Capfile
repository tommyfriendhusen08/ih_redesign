## boot cap libs
#
  load 'deploy' if respond_to?(:namespace) # cap2 differentiator
  Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

## multistage (require 'capistrano/ext/multistage')
#
  set :stages, %w( staging production )
  set :default_stage, "staging"
  set :normalize_asset_timestamps, false

  location = fetch(:stage_dir, "config/deploy")
  unless exists?(:stages)
    set :stages, Dir["#{location}/*.rb"].map { |f| File.basename(f, ".rb") }
  end
  stages.each do |name| 
    desc "Set the target stage to `#{name}'."
    task(name) do 
      set :stage, name.to_sym 
      load "#{location}/#{stage}" 
    end 
  end 
  namespace :multistage do
    desc "[internal] Ensure that a stage has been selected."
    task :ensure do
      if !exists?(:stage)
        if exists?(:default_stage)
          logger.important "Defaulting to `#{default_stage}'"
          find_and_execute_task(default_stage)
        else
          abort "No stage specified. Please specify one of: #{stages.join(', ')} (e.g. `cap #{stages.first} #{ARGV.last}')"
        end
      end 
    end
    desc "Stub out the staging config files."
    task :prepare do
      FileUtils.mkdir_p(location)
      stages.each do |name|
        file = File.join(location, name + ".rb")
        unless File.exists?(file)
          File.open(file, "w") do |f|
            f.puts "# #{name.upcase}-specific deployment configuration"
            f.puts "# please put general deployment config in config/deploy.rb"
          end
        end
      end
    end
  end
  on :start, "multistage:ensure", :except => stages + ['multistage:prepare']

## force a remote rebenv version iff a local one has been configured
#
  rails_root = File.expand_path(File.dirname(__FILE__))
  rbenv_version = File.join(rails_root, '.rbenv-version')
  if test(?e, rbenv_version)
    default_environment['RBENV_VERSION'] = IO.read(rbenv_version).strip
  end

## setup remote PATH.  it's important that this picks up rbenv!
#
  default_environment['PATH'] = (
    '/usr/local/rbenv/shims:/usr/local/rbenv/bin:' +
    default_environment.fetch('PATH', '') +
    '/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin'
  )

## suck in some app settings - we'll use the identifier to configure tons of
# stuff
#
  load File.join(File.join(rails_root, 'lib/settings.rb'))
  set(:identifier, Settings.for('data/site.yml')['identifier'])

## make rake run in the proper environment
#
  set(:rake, "bundle exec rake")

## bundler (require 'bundler/capistrano.rb')
#
  namespace :bundle do
    task :symlinks, :roles => :app do
      shared_dir = File.join(shared_path, 'bundle')
      release_dir = File.join(current_release, '.bundle')
      run("mkdir -p #{shared_dir} && rm -rf #{release_dir} && ln -s -f -F #{shared_dir} #{release_dir}")
    end

    task :install, :except => { :no_release => true } do
      bundle_dir     = fetch(:bundle_dir,         "#{fetch(:shared_path)}/bundle")
      bundle_without = [*fetch(:bundle_without,   [:development, :test])].compact
      bundle_flags   = fetch(:bundle_flags, "--deployment --quiet")
      bundle_gemfile = fetch(:bundle_gemfile,     "Gemfile")
      bundle_cmd     = fetch(:bundle_cmd, "bundle")

      args = ["--gemfile #{fetch(:latest_release)}/#{bundle_gemfile}"]
      args << "--path #{bundle_dir}" unless bundle_dir.to_s.empty?
      args << bundle_flags.to_s
      args << "--without #{bundle_without.join(" ")}" unless bundle_without.empty?
      args << "--binstubs bin"

      run "#{bundle_cmd} install #{args.join(' ')}"
    end
  end
  after 'deploy:update_code', 'bundle:symlinks'
  after "deploy:update_code", "bundle:install"


## vomit noise into campfire
#
  namespace :notify do
    desc 'alert campfire of a deploy'
    task :campfire do
      user = `git config --global --get user.name 2>/dev/null`.strip
      if user.empty?
        user = ENV['USER']
      end
      application = fetch(:application)
      stage = fetch(:stage)

      domain = 'dojo4'
      token = 'f9831e567f7237563baa64b90e65a135f223100f'
      room = "Roboto's House of Wonders"

      begin
        require 'tinder'
        campfire = Tinder::Campfire.new(domain, :token => token)
        room = campfire.rooms.detect{|_| _.name == room}
        room.speak("#{ user } deployed #{ application } to #{ stage }")
      rescue LoadError
        warn "gem install tinder # to notify #{ domain }/#{ room } campfire..."
      end
    end
  end
  after "deploy", "notify:campfire"

  namespace :deploy do
    task :build do#, :roles => :app do
      run("cd #{ deploy_to }/current &&  ./bin/middleman build; true")
    end
  end
  after 'deploy:create_symlink', 'deploy:build'

## link vhost config
#
  namespace :deploy do
    task :link_vhost do
      run "sudo ln -s #{ deploy_to }/current/config/deploy/os_files/etc/apache2/sites-enabled/#{ stage }.conf /etc/apache2/sites-enabled/#{ identifier }.#{ stage }"
      run "if sudo apache2ctl configtest; then sudo apache2ctl restart; fi; true"
    end
  end
