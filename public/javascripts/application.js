// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery.noConflict();

jQuery(document).ready(function() {
	var isChrome = /Chrome/.test(navigator.userAgent);
	if(!isChrome & jQuery.support.opacity) {
		jQuery(".tab_header a, div.tab_body").corners(); 
	}
	jQuery("#page, #toolbar, #top_right_column, #priority_column, #intro, #buzz_box, #content_text, #notification_show, .bulletin_form").corners();
	
	jQuery("abbr[class*=timeago]").timeago();	
	jQuery(":input[type=textarea]").textCounting({lengthExceededClass: 'count_over'});
	jQuery("input#priority_name, input#change_new_priority_name, input#point_other_priority_name, input#revision_other_priority_name, input#right_priority_box").autocomplete("/priorities.js");
	jQuery("input#user_login_search, input#government_official_user_name").autocomplete("/users.js");
	jQuery('#bulletin_content, #blurb_content, #message_content, #document_content, #email_template_content, #page_content').autoResize({extraSpace : 20})
	
	function addMega(){ 
	  jQuery(this).addClass("hovering"); 
	} 

	function removeMega(){ 
	  jQuery(this).removeClass("hovering"); 
	}
	var megaConfig = {
	     interval: 200,
	     sensitivity: 4,
	     over: addMega,
	     timeout: 250,
	     out: removeMega
	};
	jQuery(".mega").hoverIntent(megaConfig);

	jQuery('a#login_link').click(function() {
	  jQuery('#login_form').show('fast');
	  return false;
	});

});

function toggleAll(name)
{
  boxes = document.getElementsByClassName(name);
  for (i = 0; i < boxes.length; i++)
    if (!boxes[i].disabled)
   		{	boxes[i].checked = !boxes[i].checked ; }
}

function setAll(name,state)
{
  boxes = document.getElementsByClassName(name);
  for (i = 0; i < boxes.length; i++)
    if (!boxes[i].disabled)
   		{	boxes[i].checked = state ; }
}

// Login box

jQuery(document).ready(function() {

    jQuery(".signin").click(function(e) {
        e.preventDefault();
        jQuery("fieldset#signin_menu").toggle();
        jQuery(".signin").toggleClass("menu-open");
    });

    jQuery("fieldset#signin_menu").mouseup(function() {
        return false
    });
    jQuery(document).mouseup(function(e) {
        if(jQuery(e.target).parent("a.signin").length==0) {
            jQuery(".signin").removeClass("menu-open");
            jQuery("fieldset#signin_menu").hide();
        }
    });            

});