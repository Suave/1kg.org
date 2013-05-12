# -*- encoding : utf-8 -*-
require 'ftools'

def mkdir folder
  if File.exist? folder
    p "existed #{folder}"
  else
    Dir.mkdir folder
    p "#{folder}"
  end
end

def copy from,to,prefix=''
  if File.exist? File.join(to,"#{prefix}#{File.basename(from)}")
    p "existed #{from} -> #{to}"
  else
    File.syscopy from, File.join(to,"#{prefix}#{File.basename(from)}")
    p "#{from} -> #{to}"
  end
end

begin
  #1. 在 config 目录下添加一个 oauth 目录，用于存放各个网站的 oauth 配置信息
  mkdir "#{Rails.root.to_s}/config/oauth"
  #2. 添加一个名为 OauthToken 的模型，用于存放用户的临时凭证（request token）和令牌凭证（access token）
  copy "#{File.dirname(__FILE__)}/assets/create_oauth_tokens.rb", "#{Rails.root.to_s}/db/migrate/", Time.new.strftime('%Y%m%d%H%M%S')+"_"
rescue Exception => e
  $stderr.puts e.message
end
