class MessagesController < ApplicationController
  before_action :signed_in_user
  before_action :correct_user, only: :index
  # after_action  :set_token, only: :show

  # def show
  #   @user = User.find(params[:user_id])
  #   @message = Message.find(params[:id])
  #   @reply = Message.new
  # end

  def index
    @user = User.find(params[:user_id])
    @sent = @user.messages
    @received = @user.received_messages
  end

  def create
    @message = current_user.messages.build(message_params)
    if @message.save
      flash.now[:success] = "Message sent!"
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js { flash.now[:success] = "Message sent!" }
      end
    else
      respond_to do |format|
        format.html
        format.js
      end
    end
  end

  def destroy
  end

  def view
    @message = Message.find(params[:id])
    @message.set_viewed? unless @message.user == current_user
    head :ok
  end

  private
    def message_params
      params.require(:message).permit(:content, :receiver_id)
    end

    def correct_user
      @user = User.find(params[:user_id])
      redirect_to root_path unless current_user == @user
    end

    # def set_token
    #   @message.set_viewed?
    # end
end
