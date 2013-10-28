class MessagesController < ApplicationController
  before_action :signed_in_user
  after_action  :set_token, only: :show

  def show
    @message = Message.find(params[:id])
  end

  def create
    @message = current_user.messages.build(message_params)
    if @message.save
      flash.now[:success] = "Note sent!"
      UserMailer.message_email(@message).deliver
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js { flash.now[:success] = "Note sent!" }
      end
    else
      respond_to do |format|
        format.html
        format.js
      end
    end
  end

  private
    def message_params
      params.require(:message).permit(:content, :receiver_id)
    end

    def set_token
      @message.set_viewed?
    end
end
