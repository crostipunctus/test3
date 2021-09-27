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
    token = session.request_token(params)
    
    client = ShopifyAPI::GraphQL.client

    
    

    shop_name = client.parse <<-'GRAPHQL'
      {
        shop {
          name
          id
        }
      }
    GRAPHQL

    @shop = client.query(shop_name)

    customer_name = client.parse <<-'GRAPHQL'
    mutation {
      customerUpdate(input: {id: "gid://shopify/Customer/5510479216818", firstName: "kindred"}) {
        customer {
          id
          firstName
        
        }
      }
    }
    GRAPHQL

    #@result = client.query(customer_name)
    
    products = client.parse <<-'GRAPHQL'
    
    {
      products(first: 50) {
        edges {
          cursor
          node {
            id
            createdAt
            updatedAt
            title
            handle
            descriptionHtml
            productType
            options {
              name
              position
              values
            }
            priceRangeV2 {
              minVariantPrice {
                amount
                currencyCode
              }
              maxVariantPrice {
                amount
                currencyCode
              }
            }
          }
        }
        pageInfo {
          hasNextPage
        }
      }
    }
    GRAPHQL

  @result = client.query(products)

  @result.data.products.edges.each do |product| 
    new_product = Product.new(title: product.node.title, shop_id: 1) 
    
    new_product.save  
  end 

  poll_status_query = client.parse <<-'GRAPHQL'
      query {
        currentBulkOperation {
          id
          status
          errorCode
          createdAt
          completedAt
          objectCount
          fileSize
          url
          partialDataUrl
        }
      }
    GRAPHQL

  result_poll_status = client.query(poll_status_query)
    
   
  # images = []
  #   products = []

  #   URI.open(result_poll_status.data.current_bulk_operation.url) do |f|
  #     f.each do |line|
  #       json = JSON.parse(line)

  #       if json.key?('originalSrc') 
  #         image_id = json['id'].delete('^0-9')
  #         image_product_id = json['__parentId'].delete('^0-9')
  #         image_url = json['originalSrc']

  #         image = Image.new(shopify_image_id: image_id,                  
  #                           shopify_image_product_id: image_product_id,
  #                           url: image_url,
  #                           shop_id: context.shop.id)
  #         images << image
  #       else
  #         prodcut_id = json['id'].delete('^0-9')
  #         prodcut_title = json['title']

  #         product = Product.new(title: prodcut_title,
  #                              shopify_product_id: prodcut_id,
  #                              shop_id: context.shop.id)
  #         products << product
  #       end
  #     end
  #   end

   

    
  end
end
