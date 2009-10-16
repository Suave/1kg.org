module SchoolImport
  require 'rubygems'
  require 'open-uri'
  require 'hpricot'
  
  def s(string)
    string.gsub(/：/, '').gsub(/:/, '').gsub(/\s/, '').gsub(/ /, '').gsub(/<.*?>/, '')
  end

  def parse(raw, regex, func=nil)
    result = regex.match(raw)
    result.nil? ? '' : s(result[1])
  end

  def get_title(raw)
    regex = /名称(.*?)学/
    result = regex.match(raw)
    result.nil? ? '' : s(result[1])
  end

  def get_address(raw)
    regex = /学校地址(.*?)邮/
    result = regex.match(raw)
    result.nil? ? '' : s(result[1])
  end

  def get_master(raw)
    parse(raw, /校长姓名(.*?)学校电话/)
  end

  def get_zipcode(raw)
    parse(raw, /邮政编码(.*?)校长/)
  end

  def get_telephone(raw)
    parse(raw, /学校电话(.*?)学校联系人/)
  end

  def import_from_blog
    schools = []
    f = File.open("#{RAILS_ROOT}/db/school_meta")
    f.each_line do |line|
      title = get_title(line)
      address = get_address(line)
      address = title if address == ''
      master = get_master(line)
      zipcode = get_zipcode(line)
      telephone = get_telephone(line)
      contact = parse(line, /学校联系人(.*?)联系人电话/)
      contact_phone = parse(line, /联系人电话(.*?)联系人邮件/)
      contact_email = parse(line, /联系人邮件(.*?)学制/)

      level_amount = parse(line, /学制(.*?)教职工数/)
      teacher_amount = parse(line, /教职工数(.*?)在校生数/)
      student_amount = parse(line, /在校生数(.*?)是否有图书室/)

      book_amount = parse(line, /现有图书(.*?)是否有电脑/)
      jingdian   = parse(line, /附近景点(.*?)交通方式/)
      description = parse(line, /路程攻略(.*?)交通费用/)
      fee = parse(line, /交通费用(.*?)资料收集/)

      submitter = parse(line, /收集人(.*?)QQ/)
      submitter_qq = parse(line, /MSN(.*?)Email/i)
      submitter_email = parse(line, /Email(.*?)调查/)
      submitter_note = parse(line, /活动建议(.*?)学校需求/)

      book_needs = parse(line, /书籍类(.*?)文具类/)
      sationary_needs = parse(line, /文具类(.*?)文体类/)
      sport_needs = parse(line, /文体类(.*?)衣服类/)
      cloth_needs = parse(line, /衣服类(.*?)教具类/)
      accessory_needs = parse(line, /教具类(.*?)其他/)
      other_needs = parse(line, /其他类(.*?)学校活/)
    
      school = School.new(:user_id => 1, :title => "#{title}学")
      school.basic = SchoolBasic.new(:address => address, :zipcode => zipcode, :master => master, :telephone => telephone,
                        :level_amount => level_amount, :teacher_amount => teacher_amount, :student_amount => student_amount,
                        :book_amount => book_amount)
      school.traffic = SchoolTraffic.new(:sight => jingdian, :charge => fee, :description => description)
      school.need = SchoolNeed.new(:book => book_needs, :stationary => sationary_needs, :sport => sport_needs,
                        :cloth => cloth_needs, :accessory => accessory_needs, :other => other_needs)
      school.contact = SchoolContact.new(:name => contact, :telephone => contact_phone, :email => contact_email)
      school.local = SchoolLocal.new(:ngo_support => false, :advice => submitter_note)
      school.finder = SchoolFinder.new(:name => submitter, :email => submitter_email, :qq => submitter_qq)
      schools << school
    end
    f.close
    schools
  end
end