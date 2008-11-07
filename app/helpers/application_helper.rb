# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def nav_menu(text, url, session_name)
    if session[:nav] == session_name
      return link_to(text, url, :class => "now")
    else
      return link_to(text, url)
    end
  end
  
  def title_suffix
    "&middot;&nbsp; &middot;&nbsp; &middot;&nbsp; &middot;&nbsp; &middot;&nbsp; &middot;&nbsp;"
  end
  
  def geo_select(object, method)
    inputs = select_tag("#{method}_root", "<option></option>" + options_for_select(Geo.roots.collect{|g| [g.name, g.id]}))
    inputs << %Q"
      <span id='#{method}_container'>
        <select name='#{object}[#{method}_id]' id='#{object}_#{method}_id' disabled='disabled'>
          <option></option>
        </select>
      </span>
      <img src='/images/indicator.gif' id='#{method}_indicator' class='indicator' style='display:none' />"
      
    return inputs << observe_field("#{method}_root",
                                     :frequency => 0.25,
                                     :loading => "Element.show('#{method}_indicator')",
                                     :loaded => "Element.hide('#{method}_indicator')",
                                     :update => "#{method}_container",
                                     :url => { :controller => "geos", :action => "geo_choice" },
                                     :with => "'root='+value+'&object=#{object}&method=#{method}'"
                                  )
  end
  
end
