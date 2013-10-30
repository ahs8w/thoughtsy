# require 'carrierwave/test/matchers'

# describe ImageUploader do
#   include CarrierWave::Test::Matchers

#   before do
#     ImageUploader.enable_processing = true
#     @uploader = ImageUploader.new(@post, :image)
#   end

#   after do
#     ImageUploader.enable_processing = false
#     @uploader.remove!
#   end

#   context 'the thumb version' do
#     it "should scale down a landscape image to be exactly 64 by 64 pixels" do
#       expect(@uploader.thumb).to have_dimensions(64, 64)
#     end
#   end

#   context 'the normal version' do
#     it "should scale down an image to fit within 500 by 500 pixels" do
#       expect(@uploader).to be_no_larger_than(500, 500)
#     end
#   end
# end