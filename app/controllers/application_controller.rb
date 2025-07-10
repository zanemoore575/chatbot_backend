class ApplicationController < ActionController::API
  # The 'allow_browser' line is specific to ActionController::Base and not typically used with ActionController::API.
  # If you are building a pure API, this line can be removed.
  # If you need both HTML views and an API, consider separate controllers inheriting from Base and API respectively.

  def chat
    # Retrieve the user's message from the incoming JSON request parameters.
    user_message = params[:message]

    # Handle cases where the message is missing.
    if user_message.blank?
      render json: { error: "Message parameter is missing" }, status: :bad_request
      return
    end

    # Initialize the OpenAI client using the environment variable for the API key.
    # Make sure you have OPENAI_API_KEY set in your environment.
    client = OpenAI::Client.new

    begin
      # Send the user's message to the OpenAI API.
      response = client.chat(
        parameters: {
          model: "gpt-4", # Or your preferred model, like "gpt-3.5-turbo"
          messages: [{ role: "user", content: user_message }],
          temperature: 0.7
        }
      )

      # Extract the content from the AI's response.
      ai_response = response.dig("choices", 0, "message", "content")

      # Return the AI's response in a JSON object.
      render json: { response: ai_response }

    rescue => e
      # Handle potential errors from the API call.
      logger.error "OpenAI API error: #{e.message}"
      render json: { error: "There was a problem communicating with the AI service." }, status: :internal_server_error
    end
  end
end