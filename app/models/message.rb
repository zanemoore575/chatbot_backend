# app/models/message.rb
class Message < ApplicationRecord
    validates :content, presence: true
    validates :role, presence: true
    validates :session_id, presence: true
  
    enum role: { user: 'user', assistant: 'assistant' }
  
    scope :for_session, ->(session_id) { where(session_id: session_id) }
  end