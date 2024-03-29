#
# Cookbook Name:: btsync
# Recipe:: default
#
# Copyright 2014, Web Services
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

directory "#{node['btsync']['main_options']['storage_path']}" do
  owner node['btsync']['setup']['user']
  group node['btsync']['setup']['group']
  mode '0775'
  action :create
  recursive true
end
directory "#{node['btsync']['main_options']['pid_dir']}" do
  owner node['btsync']['setup']['user']
  group node['btsync']['setup']['group']
  mode '0775'
  recursive true
  action :create
end
directory "#{node['btsync']['main_options']['settings_file_dir']}" do
  owner node['btsync']['setup']['user']
  group node['btsync']['setup']['group']
  mode '0755'
  action :create
end
optionsFile = node['btsync']['main_options']['settings_file_dir'] + "/" + node['btsync']['main_options']['settings_file_name']

#puts YAML::dump(nodes)
my_shared_folders = Array.new
if node['btsync'].has_key?('shared_folders')
  node['btsync']['shared_folders'].each do |name,sf|
    use_relay_server = sf['use_relay_server'] != nil ? sf['use_relay_server'] : node['btsync']['shared_folder_options']['use_relay_server']
    use_tracker  = sf['use_tracker'] != nil ? sf['use_tracker'] : node['btsync']['shared_folder_options']['use_tracker']
    use_dht = sf['use_dht'] != nil ? sf['use_dht'] : node['btsync']['shared_folder_options']['use_dht']
    search_lan = sf['search_lan'] != nil ? sf['search_lan'] : node['btsync']['shared_folder_options']['search_lan']
    use_sync_trash = sf['use_sync_trash'] != nil ? sf['use_sync_trash'] : node['btsync']['shared_folder_options']['use_sync_trash']
    SyncIgnore = sf['SyncIgnore'] != nil ? sf['SyncIgnore'] : node['btsync']['shared_folder_options']['SyncIgnore']
    directory "#{sf['path']}" do
      owner node['btsync']['setup']['user']
      group node['btsync']['setup']['group']
      mode '0777'
      recursive true
      action :create
    end
    template "#{sf['path']}/.SyncIgnore" do
      source "SyncIgnore.erb"
      owner node['btsync']['setup']['user']
      group node['btsync']['setup']['group']
      mode "0644"
      notifies :restart, "service[btsync]"
      variables({:ignores => SyncIgnore})
    end
    Chef::Log.info("Added new shared folder: (#{name})\n")
    my_shared_folders << {"name"=>name,"secret"=>sf['secret'],'dir'=>sf['path'], "use_relay_server"=>use_relay_server,
                          "use_tracker"=>use_tracker,"use_dht"=>use_dht,"search_lan"=>search_lan,"use_sync_trash"=>use_sync_trash,'sync_servers'=> sf['sync_servers']}
  end
end

template optionsFile do
  source "btsync-options.json.erb"
  owner node['btsync']['setup']['user']
  group node['btsync']['setup']['group']
  mode "0644"
  variables(
    {
      :use_relay_server => node['btsync']['shared_folder_options']['use_relay_server'],
      :use_tracker => node['btsync']['shared_folder_options']['use_tracker'],
      :use_dht => node['btsync']['shared_folder_options']['use_dht'],
      :search_lan => node['btsync']['shared_folder_options']['search_lan'],
      :use_sync_trash => node['btsync']['shared_folder_options']['use_sync_trash'],
      :sharedFolders => my_shared_folders,
    }
  )
  notifies :restart, "service[btsync]"
end



# Create service
#
template "/etc/init.d/btsync" do
  source "init-script.sh.erb"
  owner node['btsync']['setup']['user']
  group node['btsync']['setup']['group']
  mode "0755"
  variables(
    {
      :btsync_user => node['btsync']['setup']['user'],
      :options_file => optionsFile,
      :pid_file => node['btsync']['main_options']['pid_dir'] + "/" + node['btsync']['main_options']['pid_file'],
      :executable => node['btsync']['setup']['bin_dir']+"/btsync"
    }
  )
end
download_url = ""
case node["languages"]["ruby"]["host_cpu"]
when "x86_64"
  download_url << "http://btsync.s3-website-us-east-1.amazonaws.com/btsync_x64.tar.gz"
when "i686"
  download_url << "http://btsync.s3-website-us-east-1.amazonaws.com/btsync_i386.tar.gz"
end

remote_file "#{Chef::Config[:file_cache_path]}/btsync.tar.gz" do
  source download_url
  backup false
  notifies :run, "execute[Unpack BTSYNC Tarball]", :immediately
  not_if "test -f #{node['btsync']['setup']['bin_dir']}/btsync"
end

execute "Unpack BTSYNC Tarball" do
  cwd "#{Chef::Config[:file_cache_path]}/"
  command "tar -xvzf #{Chef::Config[:file_cache_path]}/btsync.tar.gz; mv btsync #{node['btsync']['setup']['bin_dir']}/ && chmod +x #{node['btsync']['setup']['bin_dir']}/btsync"
  creates node['btsync']['setup']['bin_dir']+"/btsync"
  action :nothing
  notifies :restart, "service[btsync]", :immediately
end

service 'monit' do
  action :nothing
end

template "/etc/monit/conf.d/btsync.monitrc" do
  owner 'root'
  group 'root'
  mode 0644
  source "monitrc.erb"
  variables({
    :pidfile  => node['btsync']['main_options']['pid_dir'] + "/" + node['btsync']['main_options']['pid_file'],
    :upstart_name => 'btsync'
  })
  notifies :restart, 'service[monit]', :delayed
end

service 'btsync' do
  case node['platform']
  when "centos", "redhat", "amazon", "scientific", "oracle"
    service_name 'btsync'
    restart_command '/sbin/service btsync restart && sleep 1'
    reload_command '/sbin/service btsync reload && sleep 1'
  when 'debian','ubuntu'
    service_name 'btsync'
    restart_command '/usr/sbin/invoke-rc.d btsync restart && sleep 1'
    reload_command '/usr/sbin/invoke-rc.d btsync reload && sleep 1'
  when 'arch'
    service_name 'btsync'
  when 'freebsd'
    service_name 'btsync'
  end
  supports [:restart, :reload, :status]
  action [:enable, :restart]
end
