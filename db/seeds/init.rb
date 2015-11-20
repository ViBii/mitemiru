# coding: utf-8

# login_id = 'admin'というユーザを作ってから起動
# TODO: ユーザもseedで作成させるようにしたい

Role.connection.execute("TRUNCATE TABLE roles;")

Role.create(name: "admin")

user = User.where(login_id: "admin")
user.first.roles << Role.where(name: "admin")

puts "Init seed push complete!!"
