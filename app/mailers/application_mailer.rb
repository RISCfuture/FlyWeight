# @abstract
#
# Base class for all FlyWeight mailers. Currently only Devise uses the mailer
# library.

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@flyweight.herokuapp.com'
  layout 'mailer'
end
