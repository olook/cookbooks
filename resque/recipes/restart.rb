execute "restart-resque" do
  command %Q{service #{app}_resque restart}
end
