node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  database = node[:deploy][application][:database].dup
  database[:adapter] = OpsWorks::RailsConfiguration.determine_database_adapter(application, node[:deploy][application], "#{node[:deploy][application][:deploy_to]}/current", :force => node[:force_database_adapter_detection])

  template "#{deploy[:deploy_to]}/shared/config/database.yml" do
    source "database.yml.erb"
    cookbook 'site'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:database => database, :environment => deploy[:rails_env])
  end

  template "#{deploy[:deploy_to]}/shared/config/shards.yml" do
    source "shards.yml.erb"
    cookbook 'site'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:database => database, :environment => deploy[:rails_env])
  end

  template "#{deploy[:deploy_to]}/shared/config/moip.yml" do
    source "moip.yml.erb"
    cookbook 'site'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:moip => deploy[:moip], :environment => deploy[:rails_env])

    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
    end
  end

  template "#{deploy[:deploy_to]}/shared/config/redis.yml" do
    source "redis.yml.erb"
    cookbook 'site'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:redis => deploy[:redis], :environment => deploy[:rails_env])

    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
    end
  end

  template "#{node[:apache][:dir]}/sites-available/site.conf.d/local_proxy_stylist.conf" do
    cookbook "site"
    source "local_proxy_stylist.conf"
    owner "root"
    group "root"
    mode 0644

    only_if do
      File.exists?("#{node[:apache][:dir]}/sites-available/site.conf.d/")
    end
  end

  template "#{node[:apache][:dir]}/sites-available/site.conf.d/local-ssl_proxy_stylist.conf" do
    cookbook "site"
    source "local_proxy_stylist.conf"
    owner "root"
    group "root"
    mode 0644

    only_if do
      File.exists?("#{node[:apache][:dir]}/sites-available/site.conf.d/")
    end
  end
end
