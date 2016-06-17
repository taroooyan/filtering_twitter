class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :ng_word
      t.string :username

      t.timestamps null: false
    end
  end
end
