require "application_system_test_case"

class LoginTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, :verified_staff)
    @organization = @user.organization
    set_organization(@organization)
  end

  context "when logging in as a staff member" do
    should "direct to the organization's dashboard" do
      visit root_url
      click_on "Log In"

      fill_in "Email", with: @user.email
      fill_in "Password", with: @user.password
      click_on "Log in"

      assert current_path.include?(@organization.slug)
      assert_equal current_path, dashboard_index_path
    end
  end
end
