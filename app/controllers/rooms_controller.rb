class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :reject_non_related, only: [:show]

  def create #Roomは2つのEntryを持ちますので、Entryも2つ作成
    @room = Room.create
    @entry1 = Entry.create(room_id: @room.id, user_id: current_user.id) #ログインしてるユーザー
    @entry2 = Entry.create(params.require(:entry).permit(:user_id, :room_id).merge(room_id: @room.id)) #フォローされている側の情報をEntriesテーブルに保存するための記述
    redirect_to "/rooms/#{@room.id}"
  end

  def show
    @room = Room.find(params[:id]) #１つのチャットルームを表示させる必要があるので、findメソッドを使用
    if Entry.where(user_id: current_user.id, room_id: @room.id).present? #現在ログインしているユーザーのidと紐づいたチャットルームのidをwhereメソッドで探しレコードがあるか確認
      @messages = @room.messages #@messagesにアソシエーションを利用した@room.messagesという記述を代入
      @message = Message.new #新しくメッセージを作成する場合は、Message.newをし、@messageに代入
      @entries = @room.entries #@room.entriesを@entriesというインスタンス変数に入れEntriesテーブルのuser_idの情報を取得
    else
      redirect_back(fallback_location: root_path)
    end
  end



  private
  #相互フォローでないユーザーが直接チャットルームのURLを検索しても、チャットルームに入れないようにするためのメソッド
    def reject_non_related
      room = Room.find(params[:id])
      user = room.entries.where.not(user_id: current_user.id).first.user
      unless (current_user.following?(user)) && (user.following?(current_user))
        redirect_to books_path
      end
    end

end
