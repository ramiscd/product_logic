require "rails_helper"

RSpec.describe "CartsController", type: :request do
  let(:product) { create(:product, price: 10) }
  let(:cart) { create(:shopping_cart) }

  before do
    allow_any_instance_of(CartsController).to receive(:find_or_create_cart).and_return(cart)
  end

  describe "POST /cart (create)" do
    it "adds a new product to the cart" do
      post "/cart", params: { product_id: product.id, quantity: 3 }

      expect(response).to have_http_status(:ok)
      item = cart.cart_items.find_by(product_id: product.id)
      expect(item.quantity).to eq(3)
    end

    it "increments quantity when the item already exists" do
      create(:cart_item, cart: cart, product: product, quantity: 2)

      post "/cart", params: { product_id: product.id, quantity: 5 }

      expect(response).to have_http_status(:ok)
      expect(cart.cart_items.find_by(product_id: product.id).quantity).to eq(7)
    end
  end

  describe "POST /cart/add_item" do
    it "creates a cart item when it does not exist" do
      post "/cart/add_item", params: { product_id: product.id, quantity: 1 }

      item = cart.cart_items.find_by(product_id: product.id)
      expect(item.quantity).to eq(1)
    end

    it "updates quantity when it already exists" do
      create(:cart_item, cart: cart, product: product, quantity: 1)

      post "/cart/add_item", params: { product_id: product.id, quantity: 2 }

      item = cart.cart_items.find_by(product_id: product.id)
      expect(item.quantity).to eq(3)
    end
  end

  describe "DELETE /cart/:product_id" do
    it "removes a product from the cart" do
      create(:cart_item, cart: cart, product: product, quantity: 2)

      delete "/cart/#{product.id}"

      expect(response).to have_http_status(:ok)
      expect(cart.cart_items.find_by(product_id: product.id)).to be_nil
    end

    it "returns error if product does not exist" do
      delete "/cart/999999"

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Product not found")
    end

    it "returns error if product exists but is not in the cart" do
      other_product = create(:product)

      delete "/cart/#{other_product.id}"

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Product is not in the cart")
    end
  end
end
