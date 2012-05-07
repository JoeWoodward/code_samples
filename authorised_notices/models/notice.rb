class Notice < ActiveRecord::Base
  # notices belong to users
  belongs_to :users

  # image uploader for carrierwave
  mount_uploader :image, NoticeImageUploader

  # use the title for the id in the URL i.e. /notices/a-new-notice
  extend FriendlyId
  friendly_id :title, use: :slugged

  # format the attributes before saving them
  before_save :format_notice

  # validations
  validates_presence_of :title
  validates_presence_of :description
  validates_uniqueness_of :description
  # validates the phone number is only numbers and whitespace
  validates_format_of :contact_phone, :with => /[[\s]-[\d]]/x, :allow_blank => true

  def format_notice
    # format the title, set to lowercase before capitalising to prevent
    # bug
    self.title = self.title.downcase.titleize
    # if the notice includes an email set it to lowercase
    if self.contact_email
      self.contact_email = self.contact_email.downcase
    end
  end
end
