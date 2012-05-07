# app/controllers/chargify/hooks_controller.rb

# require md5 to create SHA hash
require 'digest/md5'
class Chargify::HooksController < ApplicationController
  protect_from_forgery :except => :dispatch_handler
  # verify the credibilty of the request
  before_filter :verify, :only => :dispatch_handler

  # list of events sent from chargify
  EVENTS = %w[ test signup_success signup_failure renewal_success renewal_failure payment_success payment_failure billing_date_change subscription_state_change subscription_product_change ].freeze

  def dispatch_handler
    # get the event from the chargify webhook
    event = params[:event]

    # only process if the event from the webhook is a valid event
    unless EVENTS.include? event
      render :nothing => true, :status => 404 and return
    end

    begin
      # convert the content of the webhook, bottom of page
      convert_payload
      # process the call
      self.send event
    rescue Exception => e
      render :nothing => true, :status => 422 and return
    end
  end

  # used for testing the webhook from chargify
  def test
    Rails.logger.debug "Chargify Webhook test!"
      render :nothing => true, :status => 200
  end

  def signup_success
    # if the event is signup_success find the user and activate them
    begin
      @user = User.find_by_token(@subscription.customer.reference)
      @user.chargigy_subscription_id = @subscription.id
      @user.state = @subscription.state
      @user.subscription_billing_date = @subscription.current_period_ends_at
      @user.save(:validate => false)
      render :nothing => true, :status => 200
    rescue Exception => e
      render :nothing => true, :status => 422 and return
    end
  end

  def signup_failure
    # if sign up failed find the user and deactivate their account
    begin
      @user = User.find_by_token(@subscription.customer.reference)
      @user.state = @subscription.state
      @user.chargigy_subscription_id = @subscription.id
      @user.subscription_billing_date = @subscription.current_period_ends_at
      @user.save(:validate => false)
      render :nothing => true, :status => 200
    rescue Exception => e
      render :nothing => true, :status => 422 and return
    end
  end

  def renewal_success
    begin
      @user = User.find_by_token(@subscription.customer.reference)
      @user.state = @subscription.state
      @user.chargigy_subscription_id = @subscription.id
      @user.subscription_billing_date = @subscription.current_period_ends_at
      @user.save(:validate => false)
      render :nothing => true, :status => 200
    rescue Exception => e
      render :nothing => true, :status => 422 and return
    end
  end

  def renewal_failure
    begin
      @user = User.find_by_token(@subscription.customer.reference)
      @user.state = @subscription.state
      @user.chargigy_subscription_id = @subscription.id
      @user.subscription_billing_date = @subscription.current_period_ends_at
      @user.save(:validate => false)
      render :nothing => true, :status => 200
    rescue Exception => e
      render :nothing => true, :status => 422 and return
    end
  end

  def payment_success
    begin
      @user = User.find_by_token(@subscription.customer.reference)
      @user.state = @subscription.state
      @user.chargigy_subscription_id = @subscription.id
      @user.subscription_billing_date = @subscription.current_period_ends_at
      @user.save(:validate => false)
      render :nothing => true, :status => 200
    rescue Exception => e
      render :nothing => true, :status => 422 and return
    end
  end

  def payment_failure
    begin
      @user = User.find_by_token(@subscription.customer.reference)
      @user.state = @subscription.state
      @user.chargigy_subscription_id = @subscription.id
      @user.subscription_billing_date = @subscription.current_period_ends_at
      @user.save(:validate => false)
      render :nothing => true, :status => 200
    rescue Exception => e
      render :nothing => true, :status => 422 and return
    end
  end

  def billing_date_change
    begin
      @user = User.find_by_token(@subscription.customer.reference)
      @user.state = @subscription.state
      @user.chargigy_subscription_id = @subscription.id
      @user.subscription_billing_date = @subscription.current_period_ends_at
      @user.save(:validate => false)
      render :nothing => true, :status => 200
    rescue Exception => e
      render :nothing => true, :status => 422 and return
    end
  end

  def subscription_state_change
    begin
      @user = User.find_by_token(@subscription.customer.reference)
      @user.state = @subscription.state
      @user.chargigy_subscription_id = @subscription.id
      @user.subscription_billing_date = @subscription.current_period_ends_at
      @user.save
      render :nothing => true, :status => 200
    rescue Exception => e
      render :nothing => true, :status => 422 and return
    end
  end

  # not used
  def subscription_product_change
    render :nothing => true, :status => 200
  end

  protected

  def verify
    # get the signature for the request
    if params[:signature].nil?
      params[:signature] = request.headers["HTTP_X_CHARGIFY_WEBHOOK_SIGNATURE"]
    end

    # check that the chargify site key (chargify.yml) + the content of the request is the same as the signature
    unless Digest::MD5.hexdigest(site_key + request.raw_post) == params[:signature]
      render :nothing => true, :status => :forbidden
    end
  end

  def convert_payload
    # if the content is a transaction
    if params[:payload].has_key? :transaction
      @transaction = Chargify::Transaction.new params[:payload][:transaction]
    end

    # elsif the content is a subscription
    if params[:payload].has_key? :subscription
      @subscription = Chargify::Subscription.new params[:payload][:subscription]
    end
  end

  # gets teh site key from chargify.yml
  def site_key
    ENV['CHARGIFY_SITE_KEY']
  end
end
