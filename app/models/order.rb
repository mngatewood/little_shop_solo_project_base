class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items
  has_many :items, through: :order_items

  validates_presence_of :status
  validates_presence_of :street
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :zip

  def total 
    oi = order_items.pluck("sum(quantity*price)")
    oi.sum
  end

  def self.top_shipping(metric, quantity)
    User
      .joins('join orders on orders.user_id=users.id')
      .joins('join order_items on order_items.order_id=orders.id')
      .where("orders.status != ?", :cancelled)
      .where("order_items.fulfilled=?", true)
      .order("count(orders.#{metric}) desc")
      .group("orders.#{metric}")
      .limit(quantity)
      .pluck("orders.#{metric}")
  end

  def self.top_buyers(quantity)
    User
      .select('users.*, sum(order_items.quantity*order_items.price) as total_spent')
      .joins(:orders)
      .joins('join order_items on orders.id=order_items.order_id')
      .joins('join items on order_items.item_id=items.id')
      .where('orders.status != ?', :cancelled)
      .where('order_items.fulfilled = ?', true)
      .where('users.active=?', true)
      .group(:id)
      .order('total_spent desc')
      .limit(quantity)
  end

  def self.biggest_orders(quantity)
    Order
      .select('orders.*, users.name as user_name, sum(order_items.quantity) as item_count')
      .joins(:items)
      .joins('join users on orders.user_id=users.id')
      .where('orders.status != ?', :cancelled)
      .where('order_items.fulfilled = ?', true)
      .order('item_count desc')
      .group('items.user_id, orders.id, order_items.id, users.id')
      .limit(quantity)
  end

  def no_items_fulfilled?
    binding.pry
  end
end
