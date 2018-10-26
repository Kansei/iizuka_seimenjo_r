class CustomAuthenticationFailure < Devise::FailureApp
  protected
  def redirect_url
    orders_path
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
