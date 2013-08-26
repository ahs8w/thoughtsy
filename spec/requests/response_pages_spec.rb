require 'spec_helper'

describe "ResponsePages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  
  before do
    sign_in user
    FactoryGirl.create(:post)
  end

  describe "response creation" do
    before { visit posts_path }

    describe "with invalid information" do
      before { click_link "Respond" }

      it "should not create a response" do
        expect { click_button "Respond" }.not_to change(Response, :count)
      end

      describe "error messages" do
        before { click_button "Respond" }
        it { should have_error_message('error') }
      end
    end

    describe "with valid information" do
      before do
        click_link "Respond"
        fill_in 'response_content', with: "Lorem Ipsum"
      end

      it "should create a response" do
        expect { click_button "Respond" }.to change(Response, :count).by(1)
      end
    end
  end
end
