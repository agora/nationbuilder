# Settings
default_run_options[:pty] = true
set :use_sudo, false
# set :sudo, 'sudo -p Password:'
set :stages, %w(none ccp tal medizza)
set :default_stage, "none"
require 'capistrano/ext/multistage'

set :application, "agora"

# Repo
set :scm, :git
set :deploy_via, :remote_cache
set :repository,  "git://github.com/agora/nationbuilder.git"
set :branch, "vb"

# Servers
set :user, "deploy"

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

## SOLR
# before "deploy:setup", "solr:setup"
# after "deploy:update_code", "solr:symlink"

# namespace :solr do
#   desc "Setup Solr"
#   task :setup do
#     put File.read("config/solr.yml"), "#{shared_path}/config/solr.yml"
#   end
# 
#   desc "Make symlink for solr yaml" 
#   task :symlink do
#     run "ln -nfs #{shared_path}/config/solr.yml #{release_path}/config/solr.yml" 
#   end  
# end
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

# For delayed_job
# http://www.magnionlabs.com/2009/2/28/background-job-processing-in-rails-with-delayed_job
namespace :delayed_job do
  desc "Start delayed_job process" 
  task :start, :roles => :app do
    run "#{current_path}/script/delayed_job start #{rails_env}" 
  end

  desc "Stop delayed_job process" 
  task :stop, :roles => :app do
    run "#{current_path}/script/delayed_job stop #{rails_env}" 
  end

  desc "Restart delayed_job process" 
  task :restart, :roles => :app do
    run "#{current_path}/script/delayed_job restart #{rails_env}" 
  end
end

after "deploy:start", "delayed_job:start" 
after "deploy:stop", "delayed_job:stop" 
after "deploy:restart", "delayed_job:restart"

namespace :db do
  desc "Load schema into db"
  task :load_schema, :roles => :app do
    run "#{try_sudo} cd #{current_path} && rake db:schema:load #{rails_env}"
  end
end

after "deploy:start", "db:load_schema"