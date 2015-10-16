# coding: utf-8

# login_id = 'admin'というユーザを作ってから起動
Role.connection.execute("TRUNCATE TABLE roles;")

Role.create(name: "admin")

user = User.where(login_id: "admin")
user.roles << Role.where(name: "admin")

puts "Init seed push complete!!"
