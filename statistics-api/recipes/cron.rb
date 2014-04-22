cron "run_simple_dashboard" do
  minute "*/30"
  command "cd /srv/www/statistics_api/current && bundle exec rake map_reduce:run RACK_ENV=production"
end

cron "run_periodic_dashboard" do
  minute "*/30"
  command "cd /srv/www/statistics_api/current && bundle exec rake map_reduce:run_by_period RACK_ENV=production"
end

execute "add_newline" do
  cwd current_path
  command "(crontab -l ; echo "") | crontab -"
end