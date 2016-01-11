require 'faker'
require 'date'
require 'csv'

products_headers = ["name", "department", "price", "count"]
purchases_headers = ["name", "department", "price", "user_email", "purchase_date"]
discounts_headers = ["name", "department", "original_price", "discounted_price", "availability_count"]
products = CSV.open('user3/products.csv', 'w', write_headers: true, headers: products_headers)
purchases = CSV.open('user3/purchases.csv', 'w', write_headers: true, headers: purchases_headers)
discounts = CSV.open('user3/discounts.csv', 'w', write_headers: true, headers: discounts_headers)
1000.times do |t|
  product = {}
  purchase = {}
  discount = {}
  name = Faker::Commerce.product_name
  department = Faker::Commerce.department
  price = Faker::Commerce.price
  count = Faker::Number.between(0, 100)
  # Product
  product['name'] = name
  product['department'] = department
  product['price'] = price
  product['count'] = count
  products << product.values
  # Purchase
  purchase['name'] = name
  purchase['department'] = department
  purchase['price'] = price
  purchase['user_email'] = Faker::Internet.free_email
  purchase['purchase_date'] = Faker::Date.between(Date.today - 30, Date.today).strftime("%Y-%m-%d")
  purchases << purchase.values
  # Discount
  discount['name'] = name
  discount['department'] = department
  discount['original_price'] = price
  discount['discounted_price'] = (price * 0.70).round(2)
  discount['availability_count'] = count / 2
  discounts << discount.values
end
products.close
purchases.close
discounts.close
