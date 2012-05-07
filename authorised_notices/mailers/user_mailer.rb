class UserMailer < ActionMailer::Base
  default from: "Example <example.notifier@gmail.com>"

  def notice_needs_approval(notice, type)
    @notice_title = notice.title
    # the url uses the slug because we are using the friendly_ids gem
    @url = "http://example.com/admin/notices/#{notice.slug}"
    @type = type
    # this app was hosted on heroku so the recipient was stored in a
    # config variable on heroku, this will be the email address of one
    # of the administrators
    mail(to: ENV['NEW_NOTICES_RECIPIENT'], subject: "A new notice needs your approval")
  end
end
