# -*- encoding : utf-8 -*-
every 1.day do
    rake "schools:to_json"
end

every 1.day, :at => "1:00 am" do
  rake "schools:popularity"
end
