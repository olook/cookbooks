node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]
  if File.exists?("#{release_path}/public/assets/manifest.yml")
    Chef::Log.info("Assets exist. Skipping precompile")
  else
    Chef::Log.info("Assets doesn't exist. Precompiling it")
    Chef::Log.info("sudo su deploy -c 'cd #{release_path} && /usr/local/bin/bundle exec rake assets:precompile RAILS_ENV=#{deploy[:rails_env]||'production'}")
  end
end
