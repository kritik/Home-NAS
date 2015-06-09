class CreateUserFiles < ActiveRecord::Migration
  def change
    create_table :user_files do |t|
      t.references :folder, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :state
      t.json :logs
      t.string :checksum
      t.string :extension
      t.string :file_uid
      t.string :file_name
      t.string :server_data

      t.timestamps null: false
    end
  end
end
