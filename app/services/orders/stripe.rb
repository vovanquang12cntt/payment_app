class Orders::Stripe
  def self.excute(order:)
    product = order.product

    if product.stripe_plan_name.blank?
      charge = self.excute_charge(price_cents: product.price_cents, description: product.name, card_token: order.token)
    else

    end

    unless charge&.id.blank?
      order.charge_id = charge.id
      order.set_paid
    end
  rescue Stripe::StripeError => e
    binding.pry
    order.error_message = e.message
    order.set_failed
  end

  private

  def self.excute_charge(price_cents:, description:, card_token:)
    Stripe::Charge.create({
      amount: price_cents.to_s,
      currency: "usd",
      description: description,
      source: card_token,
    })
  end
end
