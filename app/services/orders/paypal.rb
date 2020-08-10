class Orders::Paypal
  class << self
    def create_payment order, product
      payment = PayPal::SDK::REST::Payment.new({
        intent: "sale",
        payer: {
          payment_method: "paypal"
        },
        redirect_urls: {
          return_url: "http://localhost:3000/",
          cancel_url: "http://localhost:3000/"
        },
        transactions: [{
          item_list: {
            items: [
              {
                name: product.name,
                sku: product.id,
                price: product.price_cents / 100,
                currency: product.price_currency,
                quantity: 1,
              }
            ]
          },
          amount: {
            total: product.price_cents / 100,
            currency: product.price_currency,
          },
        }]
      })

      if payment.create
        order.token = payment.token
        order.charge_id = payment.id

        return payment.token if order.save
      end
    end

    def execute_payment(payment_id, payer_id)
      @order = Order.find_by charge_id: payment_id
      payment = PayPal::SDK::REST::Payment.find(payment_id)

      if payment.execute(payer_id: payer_id)
        @order.set_paypal_executed

        return @order.save
      end
    end
  end
end