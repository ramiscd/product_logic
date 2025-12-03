require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let(:product) { create(:product, price: 10) }
  let(:cart) { create(:shopping_cart) }
  let(:cart_item) { create(:cart_item, product: product, cart: cart, quantity: 3) }

  describe 'associations' do
    it 'belongs to cart' do
      expect(cart_item.cart).to eq(cart)
    end

    it 'belongs to product' do
      expect(cart_item.product).to eq(product)
    end
  end

  describe '#unit_price' do
    it 'returns the price of the product' do
      expect(cart_item.unit_price).to eq(10)
    end
  end

  describe '#total_price' do
    it 'returns unit_price multiplied by quantity' do
      expect(cart_item.total_price).to eq(30)
    end
  end
end
