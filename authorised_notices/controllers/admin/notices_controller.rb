# this controller allows admin to view all notices that haven't been
# accepted yet, accept notices, and delete inappropriate notices
class Admin::NoticesController < Admin::ApplicationController
  before_filter :require_login
  before_filter :is_admin

  def index
    # display all of the notices that haven't been accepted yet
    @notices = Notice.where(:activated => false).page(params[:page]).per(15)
  end

  def show
    @notice = Notice.find(params[:id])
    # redirect the admin to the index action if they are accessing a
    # URL of a previously activated notice.
    if @notice.activated?
      redirect_to admin_notices_path, notice: 'The notice you are trying to access has already been approved'
    else
      if @notice.user_id
        @author = User.find(@notice.user_id)
      end
    end
  rescue
    # rescue in the event of a user deleting thier notice before the admin
    # accepted it
    redirect_to admin_notices_path, notice: 'Notice no longer exists'
  end

  def destroy
    # allow the admin to delete the notice if inappropriate
    @notice = Notice.find(params[:id])
    @notice.destroy
    redirect_to admin_notices_path
  end

  def activate
    @notice = Notice.find(params[:id])
    # activate the notice
    @notice.activated = true
    # set the activated_at time so we can retrieve it later if we need to
    @notice.activated_at = Time.now
    if @notice.save
      redirect_to admin_notices_path, notice: "Successfully approved '#{@notice.title}'"
    end
  end
end
