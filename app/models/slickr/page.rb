module Slickr
  # class Page
  class Page < ApplicationRecord
    self.table_name = 'slickr_pages'

    extend FriendlyId
    include Slickr::Uploadable
    include AASM

    has_paper_trail only: %i[title aasm_state content published_content drafts],
                    meta: { content_changed: :content_changed? }

    friendly_id :title, use: %i[slugged finders]

    has_one_slickr_upload(:slickr_page_header_image, :header_image)
    has_many_slickr_uploads(:slickr_page_gallery_images, :gallery_images)
    has_many :slickr_navigations,
             foreign_key: 'slickr_page_id',
             class_name: 'Slickr::Navigation',
             dependent: :destroy
    has_many :drafts,
             foreign_key: 'slickr_page_id',
             class_name: 'Draft',
             dependent: :destroy
    has_one :active_draft, class_name: 'Slickr::Page::Draft'
    has_one :published_draft, class_name: 'Slickr::Page::Draft'

    before_create :create_content_areas
    after_create :create_draft, :activate_draft
    before_save :set_date_in_publish_schedule_time

    validates_presence_of :title, :layout, unless: :type_draft?
    validates_presence_of :publish_schedule_date, if: :publish_schedule_time?
    validates_presence_of :publish_schedule_time, if: :publish_schedule_date?

    scope :not_draft, -> { where(type: nil) }

    aasm(:status, column: :aasm_state) do
      state :draft, initial: true
      state :published

      event :publish do
        transitions from: :draft, to: :published
      end

      event :unpublish do
        transitions from: :published, to: :draft
      end
    end

    scope(:no_root_or_page_navs, lambda do
      includes(:slickr_navigations)
      .where(type: nil, slickr_navigations: { id: nil })
    end)

    scope(:has_root_or_page_navs, lambda do
      includes(:slickr_navigations)
      .where(type: nil)
      .where.not(slickr_navigations: { id: nil })
    end)

    def content
      return self[:content].to_json if self[:content].is_a? Hash
      self[:content]
    end

    def display_title
      title
    end

    def published
      published?
    end

    def page_header_image
      return { id: nil, path: nil } if header_image.nil?
      { id: header_image.id, path: header_image.image_url(:m_limit) }
    end

    def create_content_areas
      self.content = {
        "entityMap": {},
        "blocks": [
          {
            "key": SecureRandom.hex(3),
            "text": "",
            "type": "unstyled",
            "depth": 0,
            "inlineStyleRanges": [],
            "entityRanges": [],
            "data": {}
          }
        ]
      };
    end

    def create_draft
      drafts.create
    end

    def activate_draft
      drafts.first.activate
    end

    def preview_page
      Rails.application.routes.url_helpers.preview_admin_slickr_page_path(self.id)
    end

    def admin_unpublish_path
      Rails.application.routes.url_helpers.unpublish_admin_slickr_page_path(self.id)
    end

    def admin_publish_path
      Rails.application.routes.url_helpers.publish_admin_slickr_page_path(self.id)
    end

    def admin_delete_page_path
      Rails.application.routes.url_helpers.admin_slickr_page_path(self.id)
    end

    def edit_page_path
      Rails.application.routes.url_helpers.edit_admin_slickr_page_path(self.id)
    end

    def admin_preview_page_path
      Rails.application.routes.url_helpers.preview_admin_slickr_page_path(self.id)
    end

    def change_position_admin_page
      Rails.application.routes.url_helpers.change_position_admin_slickr_page_path(self.id)
    end

    def admin_page_path
      Rails.application.routes.url_helpers.admin_slickr_page_path(self.id)
    end

    def admin_image_index_path
      Rails.application.routes.url_helpers.admin_slickr_media_uploads_path
    end

    def admin_return_media_path
      Rails.application.routes.url_helpers
           .return_media_path_admin_slickr_media_uploads_path
    end

    private

    def type_draft?
      type == 'Slickr::Page::Draft'
    end

    def set_date_in_publish_schedule_time
      return if publish_schedule_date.nil?
      self.publish_schedule_time = Time.new(
        publish_schedule_date.year, publish_schedule_date.month,
        publish_schedule_date.day, self.publish_schedule_time.hour,
        self.publish_schedule_time.min, 0
      )
    end
  end
end
