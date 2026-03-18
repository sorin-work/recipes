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
end
