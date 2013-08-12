require 'spec_helper'

describe "StaticPages" do
  
  describe "Home page" do
    
    it "should have the content 'Thoughtsy'" do
      visit '/static_pages/home'
      expect(page).to have_content('Thoughtsy')
    end
  end

  describe "About page" do

  end

  describe "Help page" do

  end
end
