class OrdersController < ApplicationController
  before_action :prepare_orders, only: :paypal_create_payment

  def index
    @products = Product.all
    @products_purchase = Product.where(stripe_plan_name: nil, paypal_plan_name: nil)
    @products_subscription = @products - @products_purchase
  end

  def checkout
    if order_params[:payment_gateway] == "stripe"
      prepare_orders
      Orders::Stripe.excute(order: @order, user: current_user)
    else
      @order = Order.find_by charge_id: order_params[:charge_id]
      @order.set_paid
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

  def paypal_create_payment
    result = Orders::Paypal.create_payment(@order, @product)

    if result
      render json: {token: result}, status: :ok
    else
      render json: {error: "Something went wrong!"}, status: :unprocessable_entity
    end
  end

  def paypal_execute_payment
    result = Orders::Paypal.execute_payment(params[:payment_id], params[:payer_id])

    if result
      render json: {}, status: :ok
    else
      render json: {error: "Something went wrong"}, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:orders).permit(:payment_gateway, :product_id, :token, :charge_id)
  end

  def prepare_orders
    @order = Order.new order_params
    @product = Product.find order_params[:product_id]
    @order.price_cents = @product.price_cents
    @order.user_id = current_user.id
  end
end
