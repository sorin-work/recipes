class AccountsController < ApplicationController
  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(params.expect(user: %i[ name email_address ]))
      redirect_to edit_account_path, notice: "Account updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Deletes the account and everything in it. Asks for the password so a
  # borrowed, signed-in laptop can't do it.
  def destroy
    @user = Current.user
    if @user.authenticate(params[:password].to_s)
      @user.destroy!
      cookies.delete(:session_id)
      redirect_to new_session_path, notice: "Your account and all your recipes have been deleted.", status: :see_other
    else
      redirect_to edit_account_path, alert: "That password isn't right, so nothing was deleted.", status: :see_other
    end
  end
end
