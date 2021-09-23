# frozen_string_literal: true
class Shop < ActiveRecord::Base
  include ShopifyApp::ShopSessionStorageWithScopes

  def api_version
    ShopifyApp.configuration.api_version
    ShopifyAPI::Base.api_version = '2021-07'
    session = ShopifyAPI::Session.new(domain: "goobiebuildstest.myshopify.com", token: Shop.first.shopify_token, api_version: "2021-07")
    
  end

 
end
