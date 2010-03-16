# App
set(:rails_env) { stage }
set :customer, "tal"
set(:deploy_to) { "/u/apps/#{customer}_#{application}" } # Default: /u/apps/
set :default_lang, "is"

set :domain, "a3.agora.is"
role :web, domain # Web server
role :app, domain # App server
role :db,  domain, :primary => true

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
        - domain: tal.is
        - domain: agora.is
      website_locked: true
      default_lang: #{default_lang}

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
      domain: talsyn.tal.is
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

before "deploy:setup", :solr
after "deploy:update_code", "solr:symlink"

# ATH d64 vs. d32 eftir kerfi
namespace :solr do
  desc "Create solr yaml in shared path" 
  task :default do
    solr_config = ERB.new <<-EOF
    # Config file for the acts_as_solr plugin.
    #
    # If you change the host or port number here, make sure you update 
    # them in your Solr config file
    development:
      url: http://127.0.0.1:8982/solr
  
    production:
      url: http://127.0.0.1:8983/solr
      jvm_options: -server -d32 -Xmx1024M -Xms64M
 
    test:
      url: http://127.0.0.1:8981/solr
    EOF
    
    run "mkdir -p #{shared_path}/config" 
    put solr_config.result, "#{shared_path}/config/solr.yml"
  end
  
  desc "Make symlink for solr yaml" 
  task :symlink do
    run "ln -nfs #{shared_path}/config/solr.yml #{release_path}/config/solr.yml" 
  end
  
end