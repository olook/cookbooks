node[:deploy].each do |app, data|

  pidfile = "/srv/www/#{app}/current/tmp/pids/#{app}_resque.pid"

  template "/etc/monit/conf.d/#{app}_resque.monitrc" do
    owner 'root'
    group 'root'
    mode 0644
    source "monitrc.erb"
    variables({
      :app_name => app,
      :pidfile  => pidfile,
      #:max_mem  => "400 MB",
    })
  end

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

  service "#{app}_resque" do
    provider Chef::Provider::Service::Upstart
    start_command %Q{service #{app}_resque start}
    stop_command %Q{service #{app}_resque stop || true}
    restart_command %Q{service #{app}_resque stop || true; service #{app}_resque start}
    action [:enable, :restart]
  end

  execute "ensure-resque-is-setup-with-monit" do
    command %Q{monit reload}
    action :run
  end

end
