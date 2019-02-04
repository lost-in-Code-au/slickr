class CreateSlickrPages < ActiveRecord::Migration[5.1]
  def change
    create_table :slickr_pages do |t|
      t.string    :title
      t.string    :slug
      t.string    :aasm_state
      t.json      :content, default: "[]"
      t.string    :type
      t.integer   :page_id
      t.integer   :active_draft_id
      t.integer   :published_draft_id
      t.text      :page_header
      t.text      :page_intro
      t.string    :layout
      t.datetime  :published_at

      t.timestamps
    end
    add_index :slickr_pages, :slug, unique: true
  end
end
