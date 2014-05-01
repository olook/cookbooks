node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]
  _action = deploy[:maintenance] == 'true' ? :create : :delete
  link "#{deploy[:deploy_to]}/current/public/system/maintenance.html" do
    to "#{deploy[:deploy_to]}/current/public/baleiando.html"
    action _action
    if _action == :delete
      only_if "test -L #{deploy[:deploy_to]}/current/public/system/maintenance.html"
    end
  end
end
