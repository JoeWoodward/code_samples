class PaymentProcessor
  # used for the initial signup flow
  def self.hosted_signup_page_for(user)

    #104305 is the id of the product, if there was more than one product we couldn't hardcode this!
    "https://#{self.subdomain}.chargify.com/h/108282/subscriptions/new?first_name=#{user.first_name}&last_name=#{user.last_name}&email=#{user.email}&reference=#{user.token}"
  end

  # used to send a user to their unique payment page in
  # the event that they need to update their payment details
  def self.update_payment_url_for(user)
    "https://#{self.subdomain}.chargify.com/update_payment/#{user.chargify_subscription_id}/#{self.secure_digest(["update_payment", user.chargify_subscription_id, self.site_key].join("--"))[0..9]}"
  end

private


  def self.site_key
    ENV['CHARGIFY_SITE_KEY']
  end

  def self.subdomain
    ENV['CHARGIFY_SUBDOMAIN']
  end

  def self.secure_digest(*args)
    Digest::SHA1.hexdigest(*args)
  end

end
