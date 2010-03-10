# Bug in Rails 2.3.3 - 2.3.5 using Ruby 1.8.7 or 1.9
# See https://rails.lighthouseapp.com/projects/8994/tickets/2340
# https://rails.lighthouseapp.com/projects/8994/tickets/2340-action-mailer-cant-deliver-mail-via-smtp-on-ruby-191#ticket-2340-14
module ActionMailer
  class Base
    def perform_delivery_smtp(mail)
      destinations = mail.destinations
      mail.ready_to_send
      sender = (mail['return-path'] && mail['return-path'].spec) || Array(mail.from).first

      smtp = Net::SMTP.new(smtp_settings[:address], smtp_settings[:port])
      smtp.enable_starttls_auto if smtp_settings[:enable_starttls_auto] && smtp.respond_to?(:enable_starttls_auto)
      smtp.start(smtp_settings[:domain], smtp_settings[:user_name], smtp_settings[:password],
                 smtp_settings[:authentication]) do |smtp|
        smtp.sendmail(mail.encoded, sender, destinations)
      end
    end
  end
end