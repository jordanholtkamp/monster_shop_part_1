class SessionsController < ApplicationController

  def new
    if current_user
      login(current_user)
      flash[:success] = "#{current_user.name}, you are already logged in!"
    else
      render :new
    end
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      login(user)
    else
      flash[:error] = 'Invalid email or password'
      render :new
    end
  end

  def destroy
    session.clear
    flash[:success] = "You have been logged out"
    redirect_to '/'
  end

  private

  def login(user)
    if user.default?
      redirect_to '/profile'
    elsif user.merchant_employee? || user.merchant_admin?
      redirect_to '/merchant'
    elsif user.admin?
      redirect_to '/admin'
    end
    session[:user_id] = user.id
    flash[:success] = "Welcome, #{user.name}, you are logged in!"
  end

end
