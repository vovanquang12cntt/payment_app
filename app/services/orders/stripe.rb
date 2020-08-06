class Orders::Stripe
  def self.excute(order:, user:)
    product = order.product

    if product.stripe_plan_name.blank?
      charge = self.excute_charge(price_cents: product.price_cents, description: product.name, card_token: order.token)
    else
      stripe_customer = self.find_or_create_customer(card_token: order.token, customer_id: user.stripe_customer_id, email: user.email)

      if stripe_customer
        user.update stripe_customer_id: stripe_customer.id
        order.customer_id = stripe_customer.id

        charge = self.excute_subscriptions(customer: stripe_customer, plan: product.stripe_plan_name)
      end
    end

    unless charge&.id.blank?
      order.charge_id = charge.id
      order.set_paid
    end
  rescue Stripe::StripeError => e
    order.error_message = e.message
    order.set_failed
  end

  private

  class << self
    def excute_charge(price_cents:, description:, card_token:)
      Stripe::Charge.create({
        amount: price_cents.to_s,
        currency: "usd",
        description: description,
        source: card_token,
      })
    end

    def excute_subscriptions(customer:, plan:)
      customer.subscriptions.create({
        plan: plan
      })
    end

    def find_or_create_customer(card_token:, customer_id:, email:)
      if customer_id
        stripe_customer = Stripe::Customer.retrieve(id: customer_id)

        if stripe_customer
          Stripe::Customer.update(stripe_customer.id, { source: card_token })
        end
      else
        stripe_customer = Stripe::Customer.create(
          email: email,
          source: card_token
        )
      end

      stripe_customer
    end
  end
end
