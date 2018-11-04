class AddressesController < ApplicationController

  def new
    @user = User.find(params[:user_id])
    @address = Address.new
  end

  def create
    @user = User.find(params[:user_id])
    @address = @user.addresses.new(address_params)
    if @address.save
      flash[:success] = "New address saved."
      redirect_to profile_path
    else
      flash[:error] = "Address could not be saved."
      render :new
    end
  end

  def edit
    @user = User.find(params[:user_id])
    @address = Address.find(params[:id])
  end

  def update
    @user = User.find(params[:user_id])
    @address = Address.find(params[:id])
    if @address.update(address_params)
      flash[:success] = "Address updated."
      redirect_to profile_path
    else
      flash[:error] = "Address could not be saved."
      render :edit
    end
  end

  def default
    @user = User.find(params[:user_id])
    @address = Address.find(params[:address_id])
    @address.set_as_default(@user)
    flash[:notice] = "Default address updated."
    redirect_to profile_path
  end

  def destroy
    @address = Address.find(params[:id])
    @address.update_attribute :active, false
    flash[:notice] = "Address has been deleted."
    redirect_to profile_path
  end

  private

  def address_params
    params.require(:address).permit(:street, :city, :state, :zip, :nickname)
  end

end