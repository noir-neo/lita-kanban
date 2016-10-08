require 'tracker_api'

module Lita
  module Handlers
    class Kanban < Handler
      config :pivotal_tracker_token, required: true, type: String
      config :pivotal_tracker_project_id, required: true

      route /^kanban\s+(.+)\s+(.+)/i, :kanban, command: true, help: {
        "kanban after_story_id before_story_id" => "Return stories names."
      }

      def kanban(response)
        after_story_id = response.matches[0][0]
        before_story_id = response.matches[0][1]
        titles = stories(after_story_id, before_story_id).map do |s|
          s.name
        end.join("\n")
        response.reply(titles)
      end

      def stories(after_story_id, before_story_id)
        if Lita.config.handlers.kanban.pivotal_tracker_token.nil?
          Lita.logger.error('Missing Pivotal Tracker token')
          fail 'Missing Pivotal Tracker token'
        end

        if Lita.config.handlers.kanban.pivotal_tracker_project_id.nil?
          Lita.logger.error('Missing Pivotal Tracker project id')
          fail 'Missing Pivotal Tracker project id'
        end

        TrackerApi::Client.new(token: config.pivotal_tracker_token)
          .project(config.pivotal_tracker_project_id)
          .stories(after_story_id: after_story_id, before_story_id: before_story_id)
      end

      Lita.register_handler(self)
    end
  end
end
