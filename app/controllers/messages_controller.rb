class MessagesController < ApplicationController
  before_action :signed_in_user
  before_action :correct_user, only: :index

  def index
    @user = User.find(params[:user_id])
    @sent = @user.messages
    @received = @user.received_messages
    @reply = Message.new
  end

  def create
    @message = current_user.messages.build(message_params)
    if @message.save
      @message.send_email
      respond_to do |format|
        format.html do
          redirect_to user_messages_path(current_user)
          flash[:success] = "Message sent!"
        end
        format.js { flash.now[:success] = "Message sent!" }
      end
    else
      respond_to do |format|
        format.html do
          redirect_to :back
          flash[:danger] = "Message cannot be blank!"
        end
        format.js
      end
    end
  end

  # def destroy
  # end

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
      unless current_user == @user
        flash[:info] = "Unauthorized access"
        redirect_to root_path
      end
    end
end
