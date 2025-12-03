class CartsController < ApplicationController
  before_action :load_cart

  def create
    add_item_logic
  end

  def add_item
    add_item_logic
  end

  def show
    cart = find_or_create_cart
    render json: cart_payload(cart)
  end

  def remove_product
    product = Product.find_by(id: params[:product_id])
    return render json: { error: "Product not found" }, status: :not_found unless product

    cart_item = @cart.cart_items.find_by(product_id: product.id)
    return render json: { error: "Product is not in the cart" }, status: :unprocessable_entity unless cart_item

    cart_item.destroy

    render json: cart_payload(@cart)
  end


  private

  def add_item_logic
    cart = find_or_create_cart
    product = Product.find(params[:product_id])

    cart_item = cart.cart_items.find_by(product_id: product.id)

    if cart_item
      cart_item.update(quantity: cart_item.quantity + params[:quantity].to_i)
    else
      cart.cart_items.create!(
        product: product,
        quantity: params[:quantity]
      )
    end

    render json: cart_payload(cart)
  end

  def find_or_create_cart
    if session[:cart_id]
      Cart.find(session[:cart_id])
    else
      cart = Cart.create!
      session[:cart_id] = cart.id
      cart
    end
  end

  def cart_payload(cart)
    {
      id: cart.id,
      products: cart.cart_items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.unit_price.to_f,
          total_price: item.total_price.to_f
        }
      end,
      total_price: cart.total_price.to_f
    }
  end

 
  def load_cart
    @cart = find_or_create_cart
  end
end
