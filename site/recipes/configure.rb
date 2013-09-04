node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

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
end
