[![Checks](https://github.com/feracommerce/fera-api-ruby/actions/workflows/checks.yml/badge.svg)](https://github.com/feracommerce/fera-api-ruby/actions/workflows/checks.yml)

# Fera API Ruby Client

Welcome to the Fera API gem for Ruby. This gem is Fera's official Ruby SDK and make it easy to interact with the Fera API.

Fera API Developer Docs and API Reference can be found at: [https://developers.fera.ai](developers.fera.ai)

# Installation

Install the gem and add to the application's Gemfile by executing:

```ruby
  gem 'fera', '~> 0.1'
```

# Configuration
The Fera::API gem accepts 2 [both Secret/API Key authentication](https://developers.fera.ai/docs/api-key-authentication) 
to authenticate against your own Fera store/account, or 
[Auth Token authentication](https://developers.fera.ai/docs/partners-app-authentication) to authenticate against a Fera 
store/account that you have access to with your Fera App.

You can learn more about how to obtain your API key or obtain an auth token in our [developer docs](https://developers.fera.ai).

## Configuring for your own Fera store/account
Assuming you're using the `dotenv` gem (recommended) simply set the `FERA_SECRET_KEY` env variable to your store's
secret key, then run:
```ruby
Fera::API.configure(ENV['FERA_SECRET_KEY'])
```

If you're not using the `dotenv` then just run `Fera::API.configure("sk_your_secret_key")` directly.

## Rails Setup
If you're using rails the best way to configure the gem is to add the following to your `config/initializers/fera.rb`:

```ruby
Fera::API.configure(ENV['FERA_SECRET_KEY'])
```
(And of course set the ENV variable)

## Configuring as a Fera App
If you're building a Fera Partner App, you're going to need to authenticate like this instead:
```ruby
Fera::API.configure(store_auth_token) do
  # Some code here that will run against the store which you're authenticated against
end
```
`store_auth_token` is what you get after successfully completing [OAuth flow for a Fera account/store](https://developers.fera.ai/docs/partners-app-authentication)./

This gem also comes with a helper class for working with an app:
```ruby
$fera_app = Fera::App.new(ENV['FERA_CLIENT_ID'], ENV['FERA_CLIENT_SECRET'])
```
We recommend assigning this to a global variable since the methods in the `Fera::App` instance won't vary from Fera 
store/account to store/account.


# Usage
If you've configured the gem globally because you're only working with 1 store, you can now just call Fera models just
like you would call a Rails model:
```ruby
Fera::Review.all # Returns collection of reviews.
```


### Partner App Usage
If you're building an app and want to run a method against a specific store only, you can run the same code but within
the `Fera::API` block:
```ruby
Fera::API.configure(store_auth_token) do
  Fera::Review.all # Returns collection of reviews.
end
```
If you're building a partner app on Ruby, you might also want to check out the [Fera OmniAuth Strategy gem](https://github.com/feracommerce/omniauth-fera)
that will make it easy to connect our app to Fera to get an auth token and start using this API.

# Examples
## Reviews
See https://developers.fera.ai/reference/reviews
### List all reviews
```ruby
Fera::Review.all # Returns collection of reviews.
```

### List a product's reviews
```ruby
Fera::Review.for_product(product_id: "123") # Returns collection of reviews for product with id "123".
```

### List a customer's reviews
```ruby
Fera::Review.where(customer_id: "123")
```

### Create a review
```ruby
Fera::Review.create(
  product_id: "123",
  rating: 5,
  body: "This is a great product!"
)
```

### Retrieve specific review
```ruby
Fera::Review.find("frev_abc123") # Returns review with id "frev_abc123".
```

### Update review
```ruby
review.update(body: "This is a new review body")
# OR:
review.body = "This is a new review body"
review.save!
```

### Delete review
```ruby
review.destroy!
```


## Photos and Videos (Media)
A media object may either be a photo or a video.

See https://developers.fera.ai/reference/media

### List all photos and videos
```ruby
Fera::Media.all # Returns collection of reviews.
```

### List a product's photos and videos
```ruby
Fera::Media.for_product(product_id: "123") # Returns collection of reviews for product with id "123".
```

### Create photo
```ruby
Fera::Photo.create(
  product_id: "123",
  file: "path/to/file",
  caption: "This is my photo."
)
```

### Create video
```ruby
Fera::Video.create(
  product_id: "123",
  file: "path/to/file",
  caption: "This is my video."
)
```

### Retrieve specific photo or video
```ruby
media = Fera::Media.find("fmed_abc123") # Returns photo or video with id "frev_abc123".
puts "URL to #{ media.is_photo? ? 'photo' : 'video' }: #{ media.url }"
```

### Update photo or video
```ruby
media.update(caption: "This is a new media caption")
# OR:
media.caption = "This is a new media caption"
media.save!
```

### Delete photo or video
```ruby
media.destroy!
```


## Customers
See https://developers.fera.ai/reference/customers

### List all customers
```ruby
Fera::Customer.all # Returns collection of customers.
```

### Create customer
```ruby
Fera::Customer.create(
  name: "Michael Bluth",
  email: "michael.bluth@example.com",
  external_id: "shopify_customer_1234"
)
```

### Retrieve specific customer
```ruby
Fera::Customer.find("fcus_abc123") # Returns customer with id "fcus_abc123".
```

### Update customer
```ruby
customer.update(name: "Tobias Funke")
# OR:
customer.name = "Tobias Funke"
customer.save!
```

### Delete customer
```ruby
customer.destroy!
```

## Ratings
See https://developers.fera.ai/reference/ratings

### Retrieve a specific product's rating
```ruby
rating = Fera::Rating.for_product("product_id_1")
puts "Product has #{ rating.count } reviews with an average rating of #{ rating.average }/5."
```

### List a list of product ratings
```ruby
Fera::Rating.for_products(["product_id_1", "product_id_2", "product_id_3"]) # Returns collection of ratings for product with id "123".
```

### Retrieve the store's overall rating
```ruby
rating = Fera::Rating.for_store
puts "This store is rated #{ rating.average }/5 on average by #{ rating.count } customer(s)."
```


## Other resources to check out
You can use some of the other resources the same way:
- [Webhooks](https://developers.fera.ai/reference/webhooks)
- [Store](https://developers.fera.ai/reference/store)
- [Products](https://developers.fera.ai/reference/products)

**See our [developer API reference](https://developers.fera.ai/reference) for all filters, methods and options.**

# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/feracommerce/fera-api-ruby.


### How to contribute
To contribute to the repository:

1. Fork the repository.
2. Clone the forked repository locally.
3. Create a branch descriptive of your work. For example "my_new_feature_xyz".
4. When you're done work, push up that branch to **your own forked repository** (not the main one).
5. Visit https://github.com/feracommerce/fera-api-ruby and you'll see an option to create a pull request from your forked branch to the master. Create a pull request.


# License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
