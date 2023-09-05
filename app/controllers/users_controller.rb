class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:update]

  def show
    @user = User.find(params[:id])
    @books = @user.books
    @book = Book.new
    #下記DM機能
    @currentUserEntry = Entry.where(user_id: current_user.id) #roomがcreateされた時に現在ログインしているユーザー
    @userEntry = Entry.where(user_id: @user.id) #「チャットへ」ボタンを押されたユーザー
    if @user.id == current_user.id #現在ログインしているユーザーではないという条件
    else
      @currentUserEntry.each do |cu|
        @userEntry.each do |u|
          if cu.room_id == u.room_id then #すでにroomが作成されている場合
            @isRoom = true #falseのとき（Roomを作成するとき）の条件を分岐するための記述
            @roomId = cu.room_id #それぞれEntriesテーブル内にあるroom_idが共通しているユーザー同士に対して@roomId = cu.room_idという変数を指定
          end
        end
      end
      if @isRoom #上記で作成した変数
      else #Room未作成の場合
        @room = Room.new
        @entry = Entry.new
      end
    end
  end

  def index
    @users = User.all
    @book = Book.new
    @user = current_user
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user.id), notice: "You have updated user successfully."
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to user_path(current_user)
    end
  end
end
