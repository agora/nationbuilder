# App
set(:rails_env) { stage }
set :customer, "ccp"
set(:deploy_to) { "/u/apps/#{customer}_#{application}" } # Default: /u/apps/
set :default_lang, "en"

set :domain, "hq.agora.is"
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
        - domain: ccpgames.com
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