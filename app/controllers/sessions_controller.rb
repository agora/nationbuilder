# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  layout "simple"

  def new
    @page_title = t('sessions.new.title', :government_name => current_government.name)
    @user = User.new
    @signup = Signup.new    
    unless DB_CONFIG[RAILS_ENV]['signup_domains'].nil?
      @domains = []
      DB_CONFIG[RAILS_ENV]['signup_domains'].each {|domain| @domains << domain['domain']}
    end
    respond_to do |format|
      format.html
      format.js { render_to_facebox }
    end
  end

  def create
    self.current_user = User.authenticate(params[:email], params[:password])
    respond_to do |format|
        format.html {
          if logged_in?
            if params[:remember_me] == "1"
              current_user.remember_me unless current_user.remember_token?
              cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
            end
            redirect_back_or_default('/')
            flash[:notice] = t('sessions.create.success', :user_name => current_user.name)
          else
            flash[:error] = t('sessions.create.failed')
            render :action => 'new'
          end          
        }
        format.js {
          if logged_in?
            if session[:priority_id] # they were trying to endorse a priority, so let's go ahead and add it and take htem to their priorities page immediately
              @priority = Priority.find(session[:priority_id])
              @value = session[:value].to_i
              if @priority
                if @value == 1
                  @priority.endorse(current_user,request,current_partner,@referral)
                else
                  @priority.oppose(current_user,request,current_partner,@referral)
                end
              end  
              session[:priority_id] = nil
              session[:value] = nil
            end            
            flash[:notice] = t('sessions.create.success', :user_name => current_user.name) 
            current_user.remember_me unless current_user.remember_token?
            cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
            redirect_from_facebox(request.env['HTTP_REFERER'] || '/')
          else
            if params[:region] == 'inline'
              render :update do |page|
                page.replace_html 'login_message', t('sessions.create.try_again')
              end
            else
              flash[:error] = t('sessions.create.try_again')
              render_to_facebox(:action => "new")
            end
          end          
        }
    end        
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session    
    flash[:notice] = t('sessions.destroy')
    redirect_back_or_default('/')
  end
  
end
