class Book < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_users, through: :favorites, source: :user
  #この記述のおかげで、favoriteモデルを通じて、userモデルから、favorited_usersを参照できる,bookにfavoriteしたusersの情報が取得できる

#バリデーション
  validates :title, presence: true
  validates :body, length: { minimum: 1, maximum: 200 }

#引数で渡されたユーザidがFavoritesテーブル内に存在（exists?）するかどうかを調べ存在していればtrue
  def favorited_by?(user)
    favorites.exists?(user_id: user.id)
  end

# 検索方法分岐(解説はuser.rb)
  def self.looks(search, word)
    if search == "perfect_match"
      @book = Book.where("title LIKE?","#{word}")
    elsif search == "forward_match"
      @book = Book.where("title LIKE?","#{word}%")
    elsif search == "backward_match"
      @book = Book.where("title LIKE?","%#{word}")
    elsif search == "partial_match"
      @book = Book.where("title LIKE?","%#{word}%")
    else
      @book = Book.all
    end
  end


end
