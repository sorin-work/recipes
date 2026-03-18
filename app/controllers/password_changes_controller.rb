class PasswordChangesController < ApplicationController
  def update
    @user = Current.user
    unless @user.authenticate(params[:current_password].to_s)
      redirect_to edit_account_path, alert: "Your current password isn't right.", status: :see_other
      return
    end

    if @user.update(params.expect(user: %i[ password password_confirmation ]))
      # Sign out everywhere else; this browser keeps its session.
      @user.sessions.where.not(id: Current.session.id).delete_all
      redirect_to edit_account_path, notice: "Password changed. Other devices have been signed out.", status: :see_other
    else
      redirect_to edit_account_path, alert: @user.errors.full_messages.to_sentence, status: :see_other
    end
  end
end
