class Api::V0::ConversationsController < ApplicationController

  # Note that this is always on a url like /topics/1/conversations.
  def index
    topic = current_user.topics.find_by_id(params[:topic_id])
    head :status => :not_found and return unless topic
    render :json => topic.conversations.to_json
  end

  def create
    topic = current_user.topics.find_by_id(params[:topic_id])
    head :status => :not_found and return unless topic
    conversation = topic.conversations.create()
    render :json => conversation
  end

  def show
    conversation = Conversation.find_by_id(params[:id])
    head :status => :not_found and return unless conversation
    render :json => conversation.to_json
  end

end
