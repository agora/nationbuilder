# Settings
default_run_options[:pty] = true
set :use_sudo, false
# set :sudo, 'sudo -p Password:'
set :stages, %w(staging production testing)
set :default_stage, "testing"
require 'capistrano/ext/multistage'

# App
set(:rails_env) { stage }
set :application, "ccp_agora"
set(:deploy_to) { "/u/apps/#{application}" } # Default: /u/apps/

# Repo
set :scm, :git
set :deploy_via, :remote_cache
set :repository,  "git://github.com/agora/nationbuilder.git"
set :branch, "vb"

# Servers
set :user, "deploy"
set :domain, "hq.agora.is"
role :web, domain # Web server
role :app, domain # App server
role :db,  domain, :primary => true

# Deprec
# set :ruby_vm_type,      :ree        # ree, mri
# set :web_server_type,   :nginx      # apache, nginx
# set :app_server_type,   :passenger  # passenger, mongrel
# set :db_server_type,    :mysql      # mysql, postgresql, sqlite

# Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    # top.deprec.app.restart # Deprec
    # run "#{try_sudo} kill $( passenger-memory-stats | grep 'Passenger spawn server' | awk '{ print $1 }' )" # Kill old spawn servers, Needs root access (optional, will die automatically after default timeout period)
  end
end

# Migrations
# set :rake, "rake" 
# set :rails_env, "production" 
# set :migrate_env, "" 
# set :migrate_target, :latest

## BEGIN DB
# http://shanesbrain.net/2007/5/30/managing-database-yml-with-capistrano-2-0
require 'erb'

before "deploy:setup", :db
after "deploy:update_code", "db:symlink"

namespace :db do
  desc "Create database yaml in shared path" 
  task :default do
    db_config = ERB.new <<-EOF
    base: &base
      adapter: mysql
      socket: /var/run/mysqld/mysqld.sock
      username: #{user}
      password: #{password}
      session_key: agora
      secret: 81asqZ7mb6qHLIO0jCiQdcm7EBENQNj4VNb44R3ZLCJK6Kc1YFClc3q0BpwcaVC
      twitter_login:
      twitter_password:  
      facebook_api_key:
      facebook_secret_key:
      twitter_key:
      twitter_secret_key:
      hoptoad_key:
      signup_locked: false
      signup_user: agora
      signup_password: agora123
      signup_domain_locked: true
      signup_domains:
        - domain: ccpgames.com
        - domain: agora.is
      website_locked: true

    development:
      database: #{application}_dev
      memcached_namespace: #{application}_dev
      domain:
      <<: *base

    test:
      database: #{application}_test
      memcached_namespace: #{application}_test
      domain:
      <<: *base

    production:
      database: #{application}_prod
      memcached_namespace: #{application}_prod      
      domain: ccp.agora.is
      <<: *base
    EOF

    run "mkdir -p #{shared_path}/config" 
    put db_config.result, "#{shared_path}/config/database.yml"
  end

  desc "Make symlink for database yaml" 
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
  end
end
## END DB

## SOLR
before "deploy:setup", "solr:setup"
after "deploy:update_code", "solr:symlink"

namespace :solr do
  desc "Setup Solr"
  task :setup do
    put "config/solr.yml", "#{shared_path}/config/solr.yml"
  end

  desc "Make symlink for solr yaml" 
  task :symlink do
    run "ln -nfs #{shared_path}/config/solr.yml #{release_path}/config/solr.yml" 
  end  
end
## END SOLR

# Configure Nginx, create vhost file
# after "deploy:setup", "nginx:configure"  
# after "deploy:setup", "nginx:reload"

# Nginx templates
# http://www.subreview.com/articles/6
set :nginx_remote_template, "#{deploy_to}/shared/nginx.template"
set :nginx_remote_config, "#{deploy_to}/shared/nginx.#{application}"

namespace :nginx do
  desc "Create Nginx vhost config"
  task :configure do
   # run the template  
   RunTemplate(nginx_remote_template, nginx_remote_config)

   # move the config in to sites-available
   sudo "mv #{nginx_remote_config} /usr/local/nginx/sites-available/#{application}" 

   # add a symlink into sites enabled 
   sudo "ln -s -f /usr/local/nginx/sites-available/#{application} /usr/local/nginx/sites-enabled/#{application}" 
  end

  desc "Reload Nginx"
  task :reload do
    sudo "/etc/init.d/nginx reload"
  end
end

#
# Get the template from the server,
# parse it, and place the new file back on the server
# 
def RunTemplate(remote_file_to_get,remote_file_to_put)
    # require 'erb'  #render not available in Capistrano 2
    get(remote_file_to_get,"template.tmp")      # get the remote file
    template=File.read("template.tmp")          # read it
    buffer= ERB.new(template).result(binding)   # parse it
    put buffer,remote_file_to_put               # put the result
end 
