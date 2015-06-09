class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.string :path

      t.timestamps null: false
    end
    add_index :folders, :path
  end
end
