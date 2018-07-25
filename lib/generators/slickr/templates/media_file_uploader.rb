# frozen_string_literal: true

require 'image_optim'
require 'image_processing/vips'

module Slickr
  # MediaFileUploader
  class MediaFileUploader < Shrine
    ALLOWED_TYPES = %w[application/pdf application/vnd.ms-excel].freeze
    MAX_SIZE      = 10 * 1024 * 1024 # 10 MB

    plugin :delete_raw # automatically delete processed files after uploading
    plugin :delete_promoted
    plugin :processing
    plugin :store_dimensions
    plugin :versions

    Attacher.validate do
      validate_max_size MAX_SIZE, message: 'is too large (max is 10 MB)'
      validate_mime_type_inclusion ALLOWED_TYPES
    end

    process(:store) do |io, _context|
      file = io.download

      if io.mime_type == 'application/pdf'
        image = MiniMagick::Image.new(file.path)
        page = image.pages[0]
        display_image = Tempfile.new('version', binmode: true)

        MiniMagick::Tool::Convert.new do |convert|
          convert.background 'white'
          convert.resize('1800x1800')
          convert.quality 100
          convert << page.path
          convert << display_image.path
        end
        display_image.open # refresh updated file
      else
        display_image = File.join(
          Slickr::Engine.root,
          'package/slickr/media_gallery/files/doc_image.jpg'
        )
        File.open(display_image, 'rb')
      end

      begin
        if io.mime_type == 'application/pdf'
          pipeline = ImageProcessing::Vips.source(display_image)

          l_fit =     pipeline.resize_to_fit!(762, 1080)
          thumb_fit = pipeline.resize_to_fit!(127, 180)
        else
          pipeline = ImageProcessing::Vips.source(display_image)

          l_fit =     pipeline.resize_to_fit!(127, 180)
          thumb_fit = pipeline.resize_to_fit!(127, 180)
        end
        file.close!

        { original: io, large: l_fit, thumb: thumb_fit }
      rescue Vips::Error
        {}
      end
    end

    def generate_location(io, context)
      path = super[/^(.*[\\\/])/]
      version = context[:version]
      is_original = version.nil? || version == :original
      return path + context[:metadata]['filename'] if is_original
      orig_filename = context[:record].file_data['metadata']['filename']
      orig_filename_without_type = (/.*(?=\.)/.match orig_filename).to_s
      image_type = context[:metadata]['filename'].split('.')[-1]
      filename = "#{version}-#{orig_filename_without_type}.#{image_type}"
      path + filename
    end
  end
end
