app = node['statistics-api']

apps_root = "/srv/statistics-api"

remote_source = "https://github.com/olook/statistics-api/archive/#{app['ref']}.zip"
current_path = "#{apps_root}/current"
shared_path = "#{apps_root}/shared"
revisions_path = "#{apps_root}/revisions"

revision_path = "#{revisions_path}/#{app['ref']}"
revision_file = "#{revision_path}.zip"

package 'unzip'

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
    ln -sfn #{shared_path}/log #{revision_path}/log
    ln -sfn #{shared_path}/tmp #{revision_path}/tmp
    ln -sfn #{revision_path} #{current_path}
  EOF
end

execute "bundle install" do
  cwd current_path
  command "bundle install --without=test,development"
end

service "puma" do
  provider Chef::Provider::Service::Upstart
  supports :start => true, :stop => true, :restart => true, :status => true
  action [:stop, :start]
end
