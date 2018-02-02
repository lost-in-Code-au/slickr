if ActiveRecord::Base.connection.tables.exclude?('slickr_event_logs')
  class CreateSlickrEventLogs < ActiveRecord::Migration[5.1]
    def change
      create_table :slickr_event_logs do |t|
        t.string :action
        t.references :eventable, polymorphic: true
        t.references :admin_user, foreign_key: true

        t.timestamps
      end
    end
  end
end
