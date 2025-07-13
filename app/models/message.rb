# app/models/message.rb
class Message < ApplicationRecord
  validates :content, presence: true
  validates :role, presence: true, inclusion: { in: %w[user assistant] }
  validates :session_id, presence: true

  # Define the enum with the correct syntax
  enum :role, { user: 'user', assistant: 'assistant' }, default: :user

  scope :for_session, ->(session_id) { where(session_id: session_id) }
end