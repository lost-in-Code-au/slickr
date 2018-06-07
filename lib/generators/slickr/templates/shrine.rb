require 'shrine'
require 'shrine/storage/file_system'

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("public", prefix: 'uploads/cache'),
  store: Shrine::Storage::FileSystem.new("public", prefix: 'uploads/store')
}

# ORM
Shrine.plugin :activerecord

# Model
Shrine.plugin :cached_attachment_data # retain cached file across form redisplays
Shrine.plugin :remove_attachment # delete attachments through checkboxes on the web form
Shrine.plugin :validation_helpers

# Metadata
Shrine.plugin :add_metadata # Allows extracting additional metadata values
Shrine.plugin :determine_mime_type # stores the MIME type of the uploaded file
Shrine.plugin :infer_extension # Deduce appropriate file extension based on the MIME type
Shrine.plugin :restore_cached_data # Re-extracts cached file's metadata on model assignment

# Storage
Shrine.plugin :pretty_location # more organized directory structure on the storage

# Other
Shrine.plugin :logging, logger: Rails.logger