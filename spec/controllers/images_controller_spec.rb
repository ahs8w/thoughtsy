require 'spec_helper'

describe ImagesController do
  let(:user) { FactoryGirl.create(:user) }

  # context "with JS" do
  #   before { sign_in user, no_capybara: true }

  #   describe "#GET new" do
  #     it "works" do
  #       expect do
  #         xhr :get, :new
  #       end.to render_template :new
  #     end
  #   end
  # end

  context "in html format" do
    before { sign_in user }

    describe "#GET new" do
      
      it "displays correct page" do
        expect do
          get :new
        end.to render_template :new
      end
    end
  end
end