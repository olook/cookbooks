cron "run_simple_dashboard" do
  user "deploy"
  minute "*/30"
  command "cd /srv/www/statistics_api/current && bundle exec rake map_reduce:run RACK_ENV=production"
end

cron "run_periodic_dashboard" do
  user "deploy"
  minute "*/30"
  command "cd /srv/www/statistics_api/current && bundle exec rake map_reduce:run_by_period RACK_ENV=production"
end

