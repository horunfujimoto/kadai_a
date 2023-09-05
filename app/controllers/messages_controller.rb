class MessagesController < ApplicationController

  def create
    #user_idが current_user.idでroom_idが params[:message]の room_idであるEntryが存在するか
    if Entry.where(user_id: current_user.id, room_id: params[:message][:room_id]).present? #?マーク忘れてた
      @message = Message.new(message_params)
      @message.user_id = current_user.id
      @message.save
    else
      flash[:alert] = "メッセージ送信に失敗しました。"
    end
    render :validater unless @message.save #@messageが保存されなかった場合、validaterにrenderする
  end

  private

    def message_params
      params.require(:message).permit(:user_id, :room_id, :content)
    end

end
