node[:deploy].each do |app, data|

  template "/etc/init/#{app}_resque_scheduler.conf" do
    owner 'root'
    group 'root'
    mode 0744
    source "scheduler_upstart.erb"
    variables({
      :app_name => app
    })
  end

  execute "start-resque-scheduler" do
    command %Q{service #{app}_resque_scheduler stop || true; service #{app}_resque_scheduler start}
  end
end
