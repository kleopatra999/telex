module Serializers::UserAPI
  class Notification < Serializers::Base
    structure(:default) do |n|
      m = n.message
      {
        id:         n.id,
        created_at: time_format(n.created_at),
        title:      m.title,
        body:       m.body,
        target: {
          type: m.target_type,
          id:   m.target_id
        },
        followup:   m.followup.map { |f| {
          created_at: time_format(f.created_at),
          body:       f.body
        } }
      }
    end
  end
end
