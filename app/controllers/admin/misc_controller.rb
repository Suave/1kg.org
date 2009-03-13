class Admin::MiscController < Admin::BaseController
  def index
  end
  
  def statistics
    @city_users = User.find_by_sql "select geos.name as city_name, count(*) as users_count from users, geos where geo_id is not null and geos.id = users.geo_id group by geo_id order by users_count desc limit 15;"
  end
  
end