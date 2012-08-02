class CreateEditors < ActiveRecord::Migration
  def change
    create_table :editors do |t|
      t.integer :project_id
      t.string :filename
      t.text :contents
      t.text :settings

      t.timestamps
    end
  end
end
