include_recipe "deploy::rails"

node[:deploy].each do |app, data|

  pidfile = "/srv/www/#{app}/current/tmp/pids/#{app}_resque.pid"

  template "/etc/init/#{app}_resque.conf" do
    owner 'root'
    group 'root'
    mode 0644
    source "resque-pool-upstart.conf.erb"
    variables({
      :app_name => app,
      :pidfile  => pidfile,
    })
  end

  template "/etc/monit/conf.d/#{app}_resque.monitrc" do
    owner 'root'
    group 'root'
    mode 0644
    source "resque-pool-monitrc.erb"
    variables({
      :app_name => app,
      :pidfile  => pidfile,
    })
  end

  execute "stop-resque" do
    command %Q{service #{app}_resque stop || true}
    action :run
  end

  execute "start-resque" do
    command %Q{service #{app}_resque start}
    action :run
  end
end
