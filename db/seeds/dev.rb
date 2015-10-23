# coding: utf-8

Role.connection.execute("TRUNCATE TABLE roles;")

Project.create(
  name: "admin",
  version_repository_id: 1,
  ticket_repository_id: 1
)

puts "Dev seed push complete!!"
