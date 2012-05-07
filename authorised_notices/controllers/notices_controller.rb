class NoticesController < ApplicationController
  # verify this notice belongs to this user
  before_filter :notice_is_users, :only => [:show, :edit, :update, :destroy]

  def index
    @notices = current_user.notices
  end

  def show
    @notice = Notice.find(params[:id])
  end

  def new
    @notice = Notice.new
  end

  def edit
    @notice = Notice.find(params[:id])
  end

  def create
    @notice = current_user.notices.build(params[:notice])
    # set notice to activated = false in the controller to prevent the
    # user manipulating the form in the browser
    @notice.activated = false
    if @notice.save
      # send the administrators an email notifying them a new notice was
      # created
      UserMailer.notice_needs_approval(@notice, "created").deliver
      redirect_to your_notice_path(@notice), notice: 'Notice was successfully created.'
    else
      render :new
    end
  end

  def update
    @notice = Notice.find(params[:id])
    # if the user changes the notice it will need to be re-accepted
    params[:notice][:activated] = false
    if @notice.update_attributes(params[:notice])
      # send the administrators an email about the updated notice
      UserMailer.notice_needs_approval(@notice, "updated").deliver
      redirect_to your_notice_path(@notice), notice: 'Notice was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @notice = Notice.find(params[:id])
    @notice.destroy
    redirect_to your_notices_path
  end

  private

  def notice_is_users
    # verify that the current notice is the current users
    unless current_user.notices.include?(Notice.find(params[:id]))
      redirect_to your_notices_path
    end
  end
end
