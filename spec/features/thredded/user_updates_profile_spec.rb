require 'spec_helper'

feature 'User updating profile' do
  before do
    create_default_config
    create_default_messageboard
    sign_in_with_default_user
    visit '/users/edit'
  end

  scenario 'changes name and post filter' do
    fill_in 'Name', with: 'harry'
    select 'bbcode', from: 'user_post_filter'
    click_button 'Update Your Profile'
    visit '/users/edit'

    find('#user_name').value.should eq 'harry'
    find('#user_post_filter').value.should eq 'bbcode'
  end

  scenario 'changes their password' do
    change_password_to('secret123')
    sign_out
    sign_in_with(default_user.email, 'secret123')

    page.should have_content 'Signed in successfully.'
  end

  def change_password_to(password)
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: password
    fill_in 'user_current_password', with: 'password'
    click_button 'Change Your Password'
  end
end
