# author: Sauvik Das
# gmail smtp message sender
require 'net/smtp'

class Mailer
  def initialize
    @smtp = Net::SMTP.new 'smtp.gmail.com', 587
    @smtp.enable_starttls
  end

  def send_message(msgbody,to)
    @smtp.start('gmail.com',ENV['GMAIL_SMTP_USER'],ENV['GMAIL_SMTP_PASSWORD'],:login) do
      @smtp.send_message msgbody,ENV['GMAIL_SMTP_USER'],to
    end
  end
end
