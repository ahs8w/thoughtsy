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
  end

  describe "About page" do
    before { visit about_path }

    page_info("About")                            # page_info helper method in utilities.rb
    it_should_behave_like "all static pages"
  end

  describe "Help page" do
    before { visit help_path }

    page_info("Help")
    it_should_behave_like "all static pages"
  end
end
