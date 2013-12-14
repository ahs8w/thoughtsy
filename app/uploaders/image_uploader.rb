class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  include CarrierWaveDirect::Uploader
  # storage :fog              # default value with CarrierWaveDirect

  include CarrierWave::MimeTypes
  process :set_content_type

  # CarrierWaveDirect uses its own default uploads/.
  # def store_dir
  #   "uploads/#{Rails.env}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  # end

  # Process files as they are uploaded:
  process :resize_to_limit => [800, 800]

  # Create different versions of your uploaded files:
  version :thumb do
    process :resize_to_limit => [100, 100]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
