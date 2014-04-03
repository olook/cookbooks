app = node['statistics-api']

apps_root = "/srv/statistics-api"

remote_source = "https://github.com/olook/statistics-api/archive/#{app['ref']}.zip"
current_path = "#{apps_root}/current"
shared_path = "#{apps_root}/shared"
revisions_path = "#{apps_root}/revisions"
pidfile = "#{current_path}/pid/server.pid"

revision_path = "#{revisions_path}/#{app['ref']}"
revision_file = "#{revision_path}.zip"

[current_path, shared_path, "#{shared_path}/log", "#{shared_path}/pid", revisions_path].each do |path|
  directory path do
    recursive true
    owner "root"
    group "root"
    action :create
  end
end

execute "download-source" do
  command <<-EOF
    curl -u "#{app['github_user']}:#{app['github_pass']}" -L -o "#{revision_file}" "#{remote_source}"
  EOF
  not_if { ::File.exists?(revision_file) }
end

execute "extract-and-install" do
  cwd revisions_path
  command <<-EOF
    unzip #{revision_file}
    mv statistics-api-#{app['ref']} #{revision_path}
  EOF
  not_if { ::File.exists?(revision_path) }
end

execute "link-current" do
  command <<-EOF
    ln -sf #{shared_path}/log #{revision_path}/log
    ln -sf #{shared_path}/pid #{revision_path}/pid
    ln -sf #{revision_path} #{current_path}
  EOF
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
  action :start
end
