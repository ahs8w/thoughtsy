module ImagesHelper
  def remove_image_s3(key)
    s3 = AWS::S3.new(
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'])
    bucket = s3.buckets[ENV['FOG_DIRECTORY']]
    obj = bucket.objects[key]
    obj.delete
  end
end