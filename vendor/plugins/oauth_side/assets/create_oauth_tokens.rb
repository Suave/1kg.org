# -*- encoding : utf-8 -*-
class CreateOauthTokens < ActiveRecord::Migration
  def self.up
    create_table :oauth_tokens do |t|
      t.integer :user_id
      t.string :request_key
      t.string :request_secret
      t.string :access_key
      t.string :access_secret
      t.string :site

      t.timestamps
    end
  end

  def self.down
    drop_table :oauth_tokens
  end
end
