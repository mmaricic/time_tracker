require 'rails_helper'

feature 'user signs in', type: :feature  do
    it 'with valid credentials' do
        user = create(:user, email: 'johndoe@mail.com', password: 'password')
        
        visit sign_in_path

        fill_in 'Email', with: 'johndoe@mail.com'
        fill_in 'Password', with: 'password'
        click_button 'Sign in'

        expect(page).to have_current_path(root_path)
    end

    it 'with invalid password' do
        user =create(:user,  email: 'johndoe@mail.com', password: 'password')
        
        visit sign_in_path

        fill_in 'Email', with: 'johndoe@mail.com'
        fill_in 'Password', with: 'wrong_password'
        click_button 'Sign in'

        expect(page).to have_content 'Bad email or password'
    end
end