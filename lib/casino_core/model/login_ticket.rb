require 'casino_core/model'

class CASinoCore::Model::LoginTicket < ActiveRecord::Base
  attr_accessible :ticket
  validates :ticket, uniqueness: true

  def self.cleanup
    self.delete_all(['created_at < ?', CASinoCore.config.login_ticket[:lifetime].seconds.ago])
  end

  def to_s
    self.ticket
  end
end
