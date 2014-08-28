require 'spec_helper'

feature 'Setting up the site' do
  scenario 'bootstraps the app' do
    owner = the_site_owner
    owner.signs_in_as('joe')

    setup = setup_the_site
    setup.submit_form

    expect(setup).to be_done
    expect(owner).to be_logged_in
  end

  context 'as an anonymous user' do
    scenario 'redirects you to the sign up form' do
      setup = setup_the_site

      expect(setup).to have_a_sign_in_error_message
    end
  end

  def setup_the_site
    PageObject::Setup.new
  end

  def the_site_owner
    PageObject::Owner.new
  end
end
