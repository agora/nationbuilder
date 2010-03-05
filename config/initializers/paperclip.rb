# /Library/Ruby/Gems/1.8/gems/paperclip-2.3.1.1/lib/paperclip.rb:48: warning: already initialized constant VERSION
# http://github.com/thoughtbot/paperclip/issuesearch?state=open&q=VERSION#issue/117
if RAILS_ENV=='development'
  Paperclip.options[:image_magick_path] = "/opt/local/bin"
end