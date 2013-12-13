class ImageWorker
  def perform(id, key, type)
    obj = type.classify.find(id)
    obj.key = key
    obj.remote_image_url = obj.image.direct_fog_url(with_path: true)
    obj.save!
  end
end