node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  template "#{deploy[:deploy_to]}/shared/config/newrelic.yml" do
    source "newrelic.yml.erb"
    cookbook 'site'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:app_name => 'Resque Jobs')
  end
end
