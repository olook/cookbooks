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
    pid = File.read("/var/run/resque-scheduler.pid").to_s.strip rescue nil
    if pid && `ps #{pid} | grep #{pid}`.to_s.size > 0
      command %Q{restart #{app}_resque_scheduler}
    else
      command %Q{start #{app}_resque_scheduler}
    end
  end
end
