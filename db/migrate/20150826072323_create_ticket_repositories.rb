class CreateTicketRepositories < ActiveRecord::Migration
  def change
    create_table :ticket_repositories do |t|
      t.string :url

      t.timestamps null: false
    end
  end
end
