class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @book = Book.find(params[:id])
    @book_detail = Book.find(params[:id]) #閲覧数カウント
    unless ReadCount.find_by(user_id: current_user.id, book_id: @book_detail.id)
      current_user.read_counts.create(book_id: @book_detail.id)
    end
    @book_comment = BookComment.new
    @user = @book.user

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
    #@books = Book.all 並び替えの際に不要のためコメントアウト
    @book = Book.new
    to = Time.current.at_end_of_day #本日の23:59:59を toという変数に入れる
    from = (to - 6.day).at_beginning_of_day #to の 6日前の 0:00を fromという変数に入れる
    @books = Book.includes(:favorited_users). #Bookモデルのデータを取得と同時にfavorited_usersデータも取得
      sort_by {|x| #昇順に並び替えるメソッド
        x.favorited_users.includes(:favorites).where(created_at: from...to).size #各Bookインスタンス(x)が持つ favorited_users のうち、favoritesの created_atが fromから toの間にあるものの数を取得
      }.reverse #降順に変更

    @user = current_user
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      @user = current_user
      render :index
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render :edit
    end
  end

  def destroy
    book = Book.find(params[:id])
    book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body)
  end

  def ensure_correct_user
    @book = Book.find(params[:id])
    unless @book.user == current_user
      redirect_to books_path
    end
  end
end
