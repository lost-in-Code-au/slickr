# frozen_string_literal: true

require 'image_optim'
require 'image_processing/vips'

# Slickr::MediaImageUploader
class Slickr::MediaImageUploader < Shrine
  plugin :delete_raw # automatically delete processed files after uploading
  plugin :delete_promoted
  plugin :processing
  plugin :store_dimensions
  plugin :versions

  Attacher.validate do
    validate_max_size 10.megabytes, message: 'is too large (max is 10 MB)'
    validate_mime_type_inclusion [
      'image/jpg', 'image/jpeg', 'image/png'
    ]
  end

  process(:store) do |io, _context|
    original = io.download
    image_optim    = ImageOptim.new(pngout: false, svgo: false)
    optimized_path = image_optim.optimize_image(original.path)
    original.close!

    optimized = File.open(optimized_path, 'rb')
    pipeline = ImageProcessing::Vips.source(optimized)

    xxl_limit =   pipeline.resize_to_limit!(1500, 1500)
    xl_limit =    pipeline.resize_to_limit!(1200, 1200)
    l_limit =     pipeline.resize_to_limit!(800, 800)
    m_limit =     pipeline.resize_to_limit!(600, 600)
    s_limit =     pipeline.resize_to_limit!(400, 400)
    thumb_limit = pipeline.resize_to_limit!(200, 200)

    xxl_fill =   pipeline.resize_to_fill!(1500, 1500)
    xl_fill =    pipeline.resize_to_fill!(1200, 1200)
    l_fill =     pipeline.resize_to_fill!(800, 800)
    m_fill =     pipeline.resize_to_fill!(600, 600)
    s_fill =     pipeline.resize_to_fill!(400, 400)
    thumb_fill = pipeline.resize_to_fill!(200, 200)

    xxl_fit =   pipeline.resize_to_fit!(1500, 1500)
    xl_fit =    pipeline.resize_to_fit!(1200, 1200)
    l_fit =     pipeline.resize_to_fit!(800, 800)
    m_fit =     pipeline.resize_to_fit!(600, 600)
    s_fit =     pipeline.resize_to_fit!(400, 400)
    thumb_fit = pipeline.resize_to_fit!(200, 200)

    {
      original: io,
      xxl_limit: xxl_limit, xl_limit: xl_limit, l_limit: l_limit,
      m_limit: m_limit, s_limit: s_limit, thumb_limit: thumb_limit,
      xxl_fill: xxl_fill, xl_fill: xl_fill, l_fill: l_fill,
      m_fill: m_fill, s_fill: s_fill, thumb_fill: thumb_fill,
      xxl_fit: xxl_fit, xl_fit: xl_fit, l_fit: l_fit,
      m_fit: m_fit, s_fit: s_fit, thumb_fit: thumb_fit
    }
  end
end
