class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @book = Book.find(params[:id])
    @book_comment = BookComment.new
    @user = @book.user
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
