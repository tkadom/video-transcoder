class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :name
      t.string :description
      t.string :status
      t.string :s3_url
      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
