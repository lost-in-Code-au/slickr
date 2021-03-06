ActiveAdmin.register Slickr::Page do
  permit_params :page_title, :meta_description, :title, :page_intro,
                :page_header, :page_subheader, :layout, :slug, :og_title,
                :og_description, :twitter_title, :twitter_description,
                :content, :slug, :publish_schedule_date, :publish_schedule_time,
                slickr_page_header_image_attributes: [:slickr_media_upload_id]

  form do |f|
    if object.new_record?
      inputs do
        input :title
        input :layout, collection: options_for_select(
          Slickr::Page::LAYOUTS.map do |l|
            [l[:template].humanize, l[:template]]
          end
        )
      end
      actions
    else
      layout = Slickr::Page::LAYOUTS.find do |layout|
        layout[:template] == object.layout
      end
      exclude_records = layout[:exclude] ? layout[:exclude] : []
      tabs do
        tab 'Content' do
          inputs do
            input :title
            unless :page_header.in? exclude_records
              input :page_header, as: :text
            end
            unless :slickr_page_header_image.in? exclude_records
              render 'admin/form/image_helper',
                     f: f,
                     field: :slickr_page_header_image
              input :slickr_page_header_image, as: :text
            end
            unless :page_subheader.in? exclude_records
              input :page_subheader, as: :text
            end
            unless :page_intro.in? exclude_records
              input :page_intro, as: :text
            end
            render 'admin/form/text_area_helper', f: f, field: :content
            input :content, as: :text
          end
        end
        tab 'SEO' do
          inputs do
            input :page_title
            input :meta_description, as: :text
          end
        end
        tab 'Social Media' do
          inputs do
            input :og_title, as: :string, label: 'Facebook og title'
            input :og_description, as: :text, label: 'Facebook og description'
            input :twitter_title, as: :string
            input :twitter_description, as: :text
          end
        end
        tab 'Config' do
          inputs do
            input :layout,
                  as: :select,
                  collection: (Slickr::Page::LAYOUTS.map do |l|
                    [l[:template].humanize, l[:template]]
                  end)
            input :slug
          end
        end
        tab 'Schedule' do
          inputs do
            input :publish_schedule_date,
                  as: :datepicker,
                  label: 'Scheduled date',
                  datepicker_options: {
                    dateFormat: 'dd-MM-yy'
                  },
                  input_html: { value: f.object.new_record? \
                    ? Date.today.try(:strftime, '%d-%B-%Y')
                    : f.object.publish_schedule_date.try(:strftime, '%d-%B-%Y') }
            input :publish_schedule_time,
                  as: :time_picker,
                  label: 'Scheduled time',
                  wrapper_html: { class: 'clockpicker', 'data-autoclose': 'true' },
                  input_html: { value: f.object.new_record? \
                    ? Time.now.try(:strftime, '%H:%M')
                    : f.object.publish_schedule_time.try(:localtime).try(:strftime, '%H:%M') }
          end
        end
      end
      actions
    end
  end
end
