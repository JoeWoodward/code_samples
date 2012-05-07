class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    # create the new user
    @user = User.new(params[:user])
    # create a sha token for the user to be used by chargify
    @user.token = Digest::SHA1.hexdigest([Time.now, params[:user][:email]].join)
    # save the user
    if @user.save!
      # log the user in to the system
      login(@user.email, params[:user][:password])
      # use the payment processor class to get the URL of chargify's hosted 
      # signup page for this user
      payment_page = PaymentProcessor.hosted_signup_page_for(@user)
      # send an email to the user to notify them that the registration was successful
      UserMailer.successful_registration(@user).deliver
      # redirect to chargify
      redirect_to payment_page
    end

  rescue ActiveRecord::RecordInvalid
    render :new
  end

  def edit
    @user = current_user
  end

  def update
    if current_user.update_attributes(params[:user])
      redirect_to your_details_path, :notice => "You have successfully updated your personal details"
    else
      render :edit
    end
  end

  def show
    @user = current_user
  end

  def update_billing_detail
    # get the current user
    @user = current_user
    # redirect them to thier hosted page on chargify.com
    redirect_to PaymentProcessor.update_payment_url_for(@user)
  end

  def complete_registration
    # when a user is directed back to the site from chargify's hosted signup page
    # if the SHA token is present i.e. the request is genuine
    if User.find_by_token(params[:customer_reference])
      # initialise the user (set activation_state to active)
      initialised_user = User.init!(params[:customer_reference], params[:subscription_id])
      # save the updated user
      initialised_user.save
      redirect_to your_details_path(current_user), notice: 'Congratulations,
      you have successfully joined the YOUR NAME HERE'
    else
      redirect_to your_details_path, :notice => 'Sorry but something went wrong, please contact YOUR NAME HERE to fix the problem'
    end
  end

  def register_now
    # if a user sign up but didn't complete the process present them with a method for paying
    redirect_to PaymentProcessor.hosted_signup_page_for(current_user)
  end

  def updated_billing_info
    # this is when a user has returned from chargify after updating thier payment details
    redirect_to your_details_path, :notice => 'You have successfully updated your billing information'
  end

  def cancel_subscription
    # if the subscription exists on the chargify website
    if subscription = Chargify::Subscription.find(current_user.chargify_subscription_id.to_i)
      # set cancel_at_end_of_period to true
      subscription.cancel_at_end_of_period = true
      # save the subscription ( on chargify.com )
      subscription.save
      # set the local instance too
      current_user.is_cancelling = true
      current_user.save
      # redirect the user to a page displaying info about their subscription
      redirect_to billing_info_path, :notice => "Your subscription will expire
      on #{subscription.current_period_ends_at.strftime("%A
      #{subscription.current_period_ends_at.day.ordinalize} of %B, %Y")}"
    else
      # catch errors
      redirect_to billing_info_path, :notice => 'Sorry but something went
      wrong, please contact YOUR NAME HERE to resolve the issue'
    end
  end

  def revoke_subscription_cancellation
    # if the subscription is present on chargify.com
    if subscription = Chargify::Subscription.find(current_user.chargify_subscription_id.to_i)
      # set cancel_at_end_of_period to true
      subscription.cancel_at_end_of_period = false
      # save the subscription on chargify.com
      subscription.save
      # also set it on the local instance
      current_user.is_cancelling = false
      current_user.save
      # redirect the user to a page which displays their subscription information.
      redirect_to billing_info_path, :notice => "You have successfully revoked
      your cancellation"
    else
      redirect_to billing_info_path, :notice => 'Sorry but something went
      wrong, please contact YOUR NAME HERE to resolve the issue'
    end
  end

  def resubscribe
    # check to see if the subscription is present on chargify.com
    if subscription = Chargify::Subscription.find(current_user.chargify_subscription_id.to_i)
      # reactivate the subscription, this option is only available if 
      # the user has set their subscription to cancel_at_end_of_period
      # else their will be an option to resubscribe that redirects to a payment page
      subscription.reactivate
      subscription.reload
      # reactivate user on local server
      current_user.is_cancelling = false
      # set to pending and let chargify send a webhook to confirm.
      current_user.state = "pending"
      # save the user
      current_user.save
      redirect_to billing_info_path, :notice => "Congratulations, you have succesfully re-subscribed."
    else
      redirect_to billing_info_path, :notice => 'Sorry but something went
      wrong, please contact YOUR NAME HERE to resolve the issue'
    end
  end

  def billing_info
    # get the subscription from chargify
    subscription = Chargify::Subscription.find(current_user.chargify_subscription_id.to_i)
    # get the statements from the subscription
    @statements = subscription.statements
    # get the date of renewal
    @current_period_ends_at = subscription.current_period_ends_at
  end
end
