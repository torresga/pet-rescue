require "test_helper"
class Organizations::PetsControllerTest < ActionDispatch::IntegrationTest
  # include ActionDispatch::TestProcess

  setup do
    @organization = create(:organization)
    @pet = create(:pet)
  end

  context "GET #index" do
    should "render index template" do
      get home_index_path(script_name: "/#{@organization.slug}")

      assert_response :success
      assert_select "title", text: "#{@organization.name} | \"Pet Rescue\""
    end
  end

  context "POST #update_images" do
    should "upload file" do
      # byebug
      image = fixture_file_upload('buster1.jpg', 'image/jpeg')

      post update_images_pet_path(@pet),
        params: {append_images: [image]}

      # assert_response :success
      assert_redirected_to :show
  end
end
end