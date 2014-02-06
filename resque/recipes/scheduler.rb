node[:deploy].each do |app, data|

  template "/etc/init/#{app}_resque_scheduler.conf" do
    owner 'root'
    group 'root'
    mode 0744
    source "upstart"
    variables({
      :app_name => app
    })
  end

  execute "start-resque-scheduler" do
    command %Q{start #{app}_resque_scheduler}
  end
end
