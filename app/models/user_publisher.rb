class UserPublisher < Facebooker::Rails::Publisher

  # The new message templates are supported as well
  # First, create a method that contains your templates:
  # You may include multiple one line story templates and short story templates but only one full story template
  #  Your most specific template should be first
  #
  # Before using, you must register your template by calling register. For this example
  #  You would call UserPublisher.register_endorsement
  #  Registering the template will store the template id returned from Facebook in the
  # facebook_templates table that is created when you create your first publisher
  
  def endorsement_template
#    one_line_story_template "{*actor*} studdi <a href='{*priority_url*}'>{*priority_name*}</a> í mikilvægisröð {*position*} á <a href='{*government_url*}'>{*government_name*}</a>"
#    short_story_template "{*actor*} studdi <a href='{*priority_url*}'>{*priority_name*}</a> í mikilvægisröð {*position*} á <a href='{*government_url*}'>{*government_name*}</a>", render(:partial => "priority")
#    action_links action_link("Skoða betur","{*priority_url*}")
  end

  def create_bottom_text(priority)
    if priority
      er_up_text = priority.up_endorsements_count > 1 ? "eru" : "er"
      er_down_text = priority.down_endorsements_count > 1 ? "eru" : "er"
      "Þetta mál er núna númer #{priority.position}, #{priority.up_endorsements_count} #{er_up_text} með og #{priority.down_endorsements_count} #{er_down_text} á móti."
    else
      ""
    end
  end

  # To send a registered template, you need to create a method to set the data
  # The publisher will look up the template id from the facebook_templates table
  def endorsement(facebook_session, endorsement, priority)
    send_as :publish_stream
    txt_message = "#{facebook_session.user.name} studdi málið #{priority.name} á Hugmyndaráðuneytinu. "+create_bottom_text(priority)
    from facebook_session.user
    message ''
    attachment :name => priority.name, :href => priority.show_url, :description => txt_message
    action_links [ :text => 'Rökræða mál', :href => "#{priority.show_url}/top_points"]
  end

  def opposition_template
#    one_line_story_template "{*actor*} er á móti <a href='{*priority_url*}'>{*priority_name*}</a> í mikilvægisröð {*position*} á <a href='{*government_url*}'>{*government_name*}</a>"
#    short_story_template "{*actor*} er á móti <a href='{*priority_url*}'>{*priority_name*}</a> í mikilvægisröð {*position*} á <a href='{*government_url*}'>{*government_name*}</a>", render(:partial => "priority")
#    action_links action_link("Skoða betur","{*priority_url*}")
  end

  # To send a registered template, you need to create a method to set the data
  # The publisher will look up the template id from the facebook_templates table
  def opposition(facebook_session, endorsement, priority)
    send_as :publish_stream
    txt_message = "#{facebook_session.user.name} er á móti málinu #{priority.name} á Hugmyndaráðuneytinu. "+create_bottom_text(priority)
    from facebook_session.user
    #target facebook_session.user
    message ''
    attachment :name => priority.name, :href => priority.show_url, :description => txt_message
    action_links [ :text => 'Rökræða mál', :href => "#{priority.show_url}/top_points"]
  end  
  
  def comment_template
#    one_line_story_template "{*actor*} <a href='{*comment_url*}'>skrifaði athugasemd</a> við <a href='{*object_url*}'>{*object_name*}</a> á <a href='{*government_url*}'>{*government_name*}</a>"
#    short_story_template "{*actor*} <a href='{*comment_url*}'>skrifaði athugasemd</a> við <a href='{*object_url*}'>{*object_name*}</a> á <a href='{*government_url*}'>{*government_name*}</a>", "{*short_comment_body*}"
#    full_story_template "{*actor*} <a href='{*comment_url*}'>skrifaði athugasemd</a> við <a href='{*object_url*}'>{*object_name*}</a> á <a href='{*government_url*}'>{*government_name*}</a>", "{*comment_body*}"  
#    action_links action_link("Svara","{*comment_url*}")      
  end
  
  def comment(facebook_session, comment, activity)
    priority = activity.priority if activity.has_priority?
    if activity.has_point?
      object_url = activity.point.show_url
      object_name = activity.point.name
    elsif activity.has_document?
      object_url = activity.document.show_url
      object_name = activity.document.name
    elsif activity.has_priority?
      object_url = activity.priority.show_url
      object_name = activity.priority.name
    else
      object_url = comment.show_url
      object_name = activity.name
    end
    send_as :publish_stream
    txt_message = "#{facebook_session.user.name} skrifaði athugasemd við #{object_name} á Hugmyndaráðuneytinu: #{truncate(comment.content, :length => 400)}"
    from facebook_session.user
    message ''
    attachment :name => object_name, :href => object_url, :description => txt_message
    action_links [ :text => 'Svara', :href => comment.show_url]
    #data :object_url => object_url, :object_name => object_name, :comment_url => comment.show_url, :government_url => Government.current.homepage_url, :government_name => Government.current.name, :short_comment_body => truncate(comment.content, :length => 400), :comment_body => comment.content
  end

  def point_template
#    one_line_story_template "{*actor*} bætti við <a href='{*point_url*}'>rökum</a> við <a href='{*priority_url*}'>{*priority_name*}</a> á <a href='{*government_url*}'>{*government_name*}</a>"
#    short_story_template "{*actor*} bætti við <a href='{*point_url*}'>rökum</a> við <a href='{*priority_url*}'>{*priority_name*}</a> á <a href='{*government_url*}'>{*government_name*}</a>", render(:partial => "title_and_body")
#    action_links action_link("Skoða betur","{*point_url*}")      
  end 
  
  def point(facebook_session, point, priority)
    send_as :publish_stream
    txt_message = "#{facebook_session.user.name} bætti við rökum við #{priority.name} á Hugmyndaráðuneytinu: #{point.name_with_type} - #{point.content}"
    from facebook_session.user
    message ''
    attachment :name => point.name_with_type, :href => point.show_url, :description => txt_message
    action_links [ :text => 'Rökræða mál', :href => "#{priority.show_url}/top_points"]
#    data :priority_url => priority.show_url, :priority_name => priority.name, :point_url => point.show_url, :government_url => Government.current.homepage_url, :government_name => Government.current.name, :body => point.content, :source => point.website_link, :title => point.name_with_type
  end
  
  def document_template
#    one_line_story_template "{*actor*} bætti við <a href='{*document_url*}'>skjali</a> to <a href='{*priority_url*}'>{*priority_name*}</a> á <a href='{*government_url*}'>{*government_name*}</a>"
#    short_story_template "{*actor*} bætti við <a href='{*document_url*}'>skjali</a> to <a href='{*priority_url*}'>{*priority_name*}</a> á <a href='{*government_url*}'>{*government_name*}</a>", render(:partial => "title_and_body")
#    action_links action_link("Skoða betur","{*document_url*}")  
  end
  
  def document(facebook_session, document, priority)
    send_as :publish_stream
    txt_message = "#{facebook_session.user.name} bætti við skjali við #{priority.name} á Hugmyndaráðuneytinu: #{document.name_with_type} - #{truncate(document.content, :length => 400)}"
    from facebook_session.user
    message ''
    attachment :name => document.name_with_type, :href => document.show_url, :description => txt_message
    action_links [ :text => 'Rökræða mál', :href => "#{priority.show_url}/top_points"]
#    data :priority_url => priority.show_url, :priority_name => priority.name, :document_url => document.show_url, :government_url => Government.current.homepage_url, :government_name => Government.current.name, :body => truncate(document.content, :length => 400), :title => document.name_with_type
  end  
  
end
