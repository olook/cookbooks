cron "run_simple_dashboard" do
  minute "*/30"
  command "cd /srv/www/statistics_api/current && bundle exec rake map_reduce:run\\[production\\]"
end

cron "run_periodic_dashboard" do
  minute "*/30"
  command "cd /srv/www/statistics_api/current && bundle exec rake map_reduce:run_by_period\\[production\\]"
end

execute "add_newline" do
  command "(crontab -l ; echo "") | crontab -"
end