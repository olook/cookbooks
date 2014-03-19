include_recipe "deploy::rails"

node[:deploy].each do |app, data|

  pidfile = "/srv/www/#{app}/current/tmp/pids/#{app}_resque.pid"
  upstart_name = "#{app}_resque"

  template "/etc/init/#{upstart_name}.conf" do
    owner 'root'
    group 'root'
    mode 0644
    source "resque-pool-upstart.conf.erb"
    variables({
      :app_name => app,
      :pidfile  => pidfile,
      :upstart_name => upstart_name
    })
  end

  service 'monit' do
    action :nothing
  end

  template "/etc/monit/conf.d/#{app}_resque.monitrc" do
    owner 'root'
    group 'root'
    mode 0644
    source "monitrc.erb"
    variables({
      :app_name => app,
      :pidfile  => pidfile,
      :upstart_name => upstart_name
    })
    notifies :restart, 'service[monit]', :delayed
  end

  execute "stop-resque" do
    command %Q{service #{upstart_name} stop || true}
    action :run
  end

  execute "start-resque" do
    command %Q{service #{upstart_name} start}
    action :run
  end
end
