# -*- encoding : utf-8 -*-
class Minisite::Cnbloggercon09::DashboardController < ApplicationController
  def index
    @group = Group.find_by_slug('cnbloggercon09')
  
  end
end
