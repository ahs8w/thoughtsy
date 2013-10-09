class MessagesController < ApplicationController

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

  private
    def message_params
      params.require(:message).permit(:content, :to_id)
    end
end
