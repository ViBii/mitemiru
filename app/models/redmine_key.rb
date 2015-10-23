class RedmineKey < ActiveRecord::Base
  has_and_belongs_to_many :users

  before_save :encrypt_password

  def encrypt_password
    self.password_digest = encrypt(self.password_digest)
  end

  SECURE = 'HOGEHOGEHOGEHOGEHOGEHOGEHOGEHOGEHOGEHOGEHOGEHOGEHOGE'
  CIPHER = 'aes-256-cbc'

  # 暗号化
  def encrypt(password)
    crypt = ActiveSupport::MessageEncryptor.new(SECURE, CIPHER)
    crypt.encrypt_and_sign(password)
  end

  # 復号化
  def decrypt(password)
    crypt = ActiveSupport::MessageEncryptor.new(SECURE, CIPHER)
    crypt.decrypt_and_verify(password)
  end
end
