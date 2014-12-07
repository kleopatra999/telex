module Endpoints
  class ProducerAPI::Messages < Base
    resource("/messages") do |res|
      res.property.uuid :id

      res.link(:post) do |link|
        link.property.text :title
        link.property.text :body
        link.property.nested :target do |target|
          target.text :type
          target.text :id
        end
        link.action { create_message }
      end

      res.link(:post, "/:message_id/followups") do |link|
        link.property.text :body
        link.action { create_followup }
      end
    end

    private

    def current_producer
      Pliny::RequestStore.store.fetch(:current_producer)
    end

    def create_message
      message = Mediators::Messages::Creator.run(
        producer: current_producer,
        title:       data['title'],
        body:        data['body'],
        target_type: data['target'] && data['target']['type'],
        target_id:   data['target'] && data['target']['id']
      )

      status 201
      MultiJson.encode({id: message.id})
    rescue => e
      raise Pliny::Errors::UnprocessableEntity
    end

    def create_followup
      message = Message[id: params['message_id'], producer_id: current_producer.id]
      followup = Mediators::Followups::Creator.run(
        message: message,
        body:    data['body']
      )

     status 201
     MultiJson.encode({id: followup.id})
    rescue
      raise Pliny::Errors::UnprocessableEntity
    end
  end
end
