SPEND_THRESHOLD_AMOUNT = 5000
DISCOUNT_AT_THRESHOLD = 1000

total_eligible_price = 0

# Loop over all the items to find eligble ones and total eligible discount price
eligible_items = Input.cart.line_items.select do |line_item|
  total_eligible_price += Integer(line_item.line_price.cents.to_s)
  product = line_item.variant.product
  !product.gift_card? && product.tags.include?('spend-and-save')
end

message = ""
total_discount = (total_eligible_price/SPEND_THRESHOLD_AMOUNT).floor * DISCOUNT_AT_THRESHOLD

# Distribute the total discount across the products propotional to their price
remainder = 0.0
eligible_items.each do |line_item|
  price = Integer(line_item.line_price.cents.to_s)
  proportion =  price / total_eligible_price
  discount_float = (total_discount * proportion) + remainder
  discount = discount_float.round
  remainder =  discount_float - discount
  line_item.change_line_price(line_item.line_price - Money.new(cents: discount), message: message) unless discount == 0
end

Output.cart = Input.cart
