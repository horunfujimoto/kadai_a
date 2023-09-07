class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

#アソシエーション
  has_many :books, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :rooms, through: :entries #Entryモデルという中間テーブルを作成するため
  has_many :entries, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :read_counts, dependent: :destroy

#フォロー機能のアソシエーション
  # 自分がフォローされる（被フォロー）側の関係性
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  # 被フォロー関係を通じて参照→自分をフォローしている人
  has_many :followers, through: :reverse_of_relationships, source: :follower

  # 自分がフォローする（与フォロー）側の関係性
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  # 与フォロー関係を通じて参照→自分がフォローしている人
  has_many :followings, through: :relationships, source: :followed

  has_one_attached :profile_image

#バリデーション
  validates :name, uniqueness: true, length: { minimum: 2, maximum: 20 }
  validates :introduction, length: { maximum: 50 }


  def get_profile_image(width, height)
    unless profile_image.attached?
      file_path = Rails.root.join('app/assets/images/no_image.jpg')
      profile_image.attach(io: File.open(file_path), filename: 'default-image.jpg', content_type: 'image/jpeg')
    end
    profile_image.variant(resize_to_limit: [width, height]).processed
  end

  def follow(user)
    relationships.create(followed_id: user.id)
  end

  def unfollow(user)
    relationships.find_by(followed_id: user.id).destroy
  end

  def following?(user)
    followings.include?(user)
  end

  #検索方法分岐
  def self.looks(search, word) #looksはsearch_forメソッドでもいい
    if search == "perfect_match"
      @user = User.where("name LIKE?", "#{word}") #whereメソッドはデータベースから該当データを取得し変数に代入
    elsif search == "forward_match"
      @user = User.where("name LIKE?","#{word}%") #完全一致以外の検索方法は、#{word}の前後(もしくは両方に)、%を追記することで定義
    elsif search == "backward_match"
      @user = User.where("name LIKE?","%#{word}") #"%#{word}"は'%' + wordと記述してもよい
    elsif search == "partial_match"
      @user = User.where("name LIKE?","%#{word}%")
    else
      @user = User.all
    end
  end

end

#文字検索をしたい時はLIKE句を使う！今回はnameカラムが何タイプ（部分一致とか）に該当されるか検索
