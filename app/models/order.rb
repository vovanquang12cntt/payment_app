class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product

  enum status: { pending: 0, failed: 1, paid: 2, paypal_excuted: 3}
  enum payment_gateway: { stripe: 0, paypal: 1 }

  scope :recently_created, ->  { where(created_at: 1.minutes.ago..DateTime.now) }

  def set_paid
    self.status = Order.statuses[:paid]
  end

  def set_failed
    self.status = Order.statuses[:failed]
  end

  def set_paypal_executed
    self.status = Order.statuses[:paypal_executed]
  end
end
