require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get hello" do
    get messages_hello_url
    assert_response :success
  end
end
