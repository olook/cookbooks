apps_root = "/srv/statistics-api"

current_path = "#{apps_root}/current"
shared_path = "#{apps_root}/shared"
revisions_path = "#{apps_root}/revisions"
pidfile = "#{current_path}/pid/server.pid"

package 'unzip'

[shared_path, "#{shared_path}/log", "#{shared_path}/pid", revisions_path].each do |path|
  directory path do
    recursive true
    owner "root"
    group "root"
    action :create
  end
end

template "/etc/init/statistics-api.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source "upstart.conf.erb"
  variables({
    :pidfile  => pidfile,
    :workers_count => 16
  })
end

service "statistics-api" do
  supports :start => true, :stop => true, :restart => true
  action :nothing
end
