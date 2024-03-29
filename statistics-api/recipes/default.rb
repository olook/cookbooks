apps_root = "/srv/statistics-api"

current_path = "#{apps_root}/current"
shared_path = "#{apps_root}/shared"
revisions_path = "#{apps_root}/revisions"

package 'unzip'

[shared_path, "#{shared_path}/log", "#{shared_path}/tmp", revisions_path].each do |path|
  directory path do
    recursive true
    owner "root"
    group "root"
    action :create
  end
end

template "/etc/init/puma.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source "upstart.conf.erb"
  variables({
    current_path: current_path
  })
end
