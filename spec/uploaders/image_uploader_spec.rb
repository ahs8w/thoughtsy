# require 'carrierwave/test/matchers'

# describe ImageUploader do
#   include CarrierWave::Test::Matchers

#   before do
#     ImageUploader.enable_processing = true
#     @post = Post.new(user_id: 1)
#     @uploader = ImageUploader.new(@post, :image)
#     @uploader.store!(File.open(File.join(Rails.root, "spec/support/test.png")))
#   end

#   after do
#     ImageUploader.enable_processing = false
#     @uploader.remove!
#   end

#   context 'the thumb version' do
#     it "should scale down a landscape image to be exactly 100 by 100 pixels" do
#       expect(@uploader.thumb).to have_dimensions(100, 100)
#     end
#   end

#   context 'the normal version' do
#     it "should scale down an image to fit within 800 by 800 pixels" do
#       expect(@uploader).to be_no_larger_than(800, 800)
#     end
#   end
# end