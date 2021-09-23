# frozen_string_literal: true

class HomeController < ApplicationController
  include ShopifyApp::EmbeddedApp
  include ShopifyApp::RequireKnownShop
  include ShopifyApp::ShopAccessScopesVerification
  
 

  def index
    @shop_origin = current_shopify_domain
    @host = params[:host]
    session = ShopifyAPI::Session.new(domain: "goobiebuildstest.myshopify.com", token: Shop.first.shopify_token, api_version: "2021-07")
    ShopifyAPI::Base.activate_session(session)
    @customers = ShopifyAPI::Customer.find(:all, params: { limit: 10 })
    @products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
    token = session.request_token(params)
    client = ShopifyAPI::GraphQL.client

    shop_name = client.parse <<-'GRAPHQL'
      {
        shop {
          name
        }
      }
    GRAPHQL

    @result = client.query(shop_name)
    

  
  end
end
