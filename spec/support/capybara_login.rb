def sign_in_admin!(user)
  visit '/admin'
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_button 'Login'
end

def create_admin_in_sign_in
  admin = Spree.user_class.create(email: 'admin@admin.com', password: 'password', password_confirmation: 'password')
  role = Spree::Role.create(name: 'admin')
  role.users << admin
  sign_in_admin! admin
end