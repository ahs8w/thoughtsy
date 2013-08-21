require 'spec_helper'

describe "StaticPages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end
  
  describe "Home page" do
    before { visit root_path }

    let(:heading)    { 'Thoughtsy' }
    let(:page_title) { '' }
    it_should_behave_like "all static pages"

    describe "when not signed in" do
      it { should have_link("Sign up now!") }
      it { should_not have_link("Account") }
      it { should_not have_link("Users") }
      it { should_not have_link("view my profile") }
    end

    describe "when signed in" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
        visit root_path
      end

      it { should have_content(user.username) }
      it { should have_link("view my profile") }
      it { should have_link("Account") }
      it { should have_link("Users") }
      it { should have_button("Post") }

      describe "creating a post should update post count" do
        before do
          fill_in "post_content", with: "Lorem ipsum"
          click_button "Post"
          click_link "Thoughtsy"
        end

        it { should have_content("1 post") }

        describe "creating a second should pluralize correctly" do
          before do
            fill_in "post_content", with: "Lorem ipsum2"
            click_button "Post"          
            click_link "Thoughtsy"
          end

          it { should have_content("2 posts") }
        end
      end
    end
  end

  describe "About page" do
    before { visit about_path }

    let(:heading)    { 'How it works' }
    let(:page_title) { 'About' }
    it_should_behave_like "all static pages"
  end

  describe "Team page" do
    before { visit team_path }

    page_info("Team")                           # page_info helper method in utilities.rb
    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }

    page_info("Contact")
    it_should_behave_like "all static pages"
  end

  it "should have the correct links in the layout" do
    visit root_path
    click_link "How it works"
    expect(page).to have_title(full_title("About"))
    click_link "Thoughtsy"
    expect(page).to have_title(full_title(""))
    click_link "Team"
    expect(page).to have_title(full_title("Team"))
    click_link "Contact"
    expect(page).to have_title(full_title("Contact"))
    click_link "Thoughtsy"
    click_link "Sign up now!"
    expect(page).to have_title(full_title("Sign up"))
  end
end
