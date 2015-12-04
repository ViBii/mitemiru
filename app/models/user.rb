class User < ActiveRecord::Base
  has_many :projects
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :redmine_keys
  has_and_belongs_to_many :github_keys
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login_id]

  validates_uniqueness_of :login_id
  validates_presence_of   :login_id

  # login_idを仕様してログインするようオーバーライド
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      # 認証の条件式を変更する
      where(conditions).where(["login_id = :value", {:value => login_id}]).first
    else
      where(conditions).first
    end
  end

  # 登録時にemailを不要とする
  def email_required?
    false
  end

  # 登録時にemailを不要とする
  def email_changed?
    false
  end

  def has_role?(name)
    self.roles.where(name: name).length > 0
  end
end
