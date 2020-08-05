class OrdersController < ApplicationController
  def index
    @products = Product.all
    @products_purchase = Product.where(stripe_plan_name: nil, paypal_plan_name: nil)
  end

  def checkout
    if order_params[:payment_gateway] == "stripe"
      @order = Order.new order_params
      @order.price_cents = Product.find(order_params[:product_id]).price_cents
      @order.user_id = current_user.id

      Orders::Stripe.excute(order: @order)
    else

    end
  ensure
    if @order&.save
      if @order.paid?
        return render html: "Success"
      elsif @order.failed? && @order.error_message
        return render html: @order.error_message
      end
    end

    render html: "Failed"
  end

  private

  def order_params
    params.require(:orders).permit(:payment_gateway, :product_id, :token)
  end
end
