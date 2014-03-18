node[:deploy].each do |app, data|

  pidfile = "/srv/www/#{app}/current/tmp/pids/resque_scheduler.pid"
  upstart_name = "#{app}_resque_scheduler"

  template "/etc/init/#{upstart_name}.conf" do
    owner 'root'
    group 'root'
    mode 0644
    source "scheduler_upstart.erb"
    variables({
      :app_name => app,
      :pidfile => pidfile,
      :upstart_name => upstart_name
    })
  end

  template "/etc/monit/conf.d/#{app}_resque_scheduler.monitrc" do
    owner 'root'
    group 'root'
    mode 0644
    source "monitrc.erb"
    variables({
      :app_name => app,
      :pidfile  => pidfile,
      :upstart_name => upstart_name
    })
  end

  execute "start-resque-scheduler" do
    command %Q{service #{upstart_name} stop || true; service #{upstart_name} start}
  end
end
