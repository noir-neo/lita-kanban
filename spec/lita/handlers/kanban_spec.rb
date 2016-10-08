require "spec_helper"

describe Lita::Handlers::Kanban, lita_handler: true do
  let(:after_story_id) { 0 }
  let(:before_story_id) { 3 }

  it { is_expected.to route_command("kanban #{after_story_id} #{before_story_id}").to(:kanban) }

  describe '#kanban' do
    context 'when missing token' do
      before do
        allow(Lita.config.handlers.kanban).to receive(:pivotal_tracker_token).and_return(nil)
        allow(Lita.config.handlers.kanban).to receive(:pivotal_tracker_project_id).and_return(1)
        allow_any_instance_of(TrackerApi::Client).to receive(:project).and_return(nil)
      end

      it 'raise an error' do
        expect { send_command("kanban #{after_story_id} #{before_story_id}") }.to raise_error('Missing Pivotal Tracker token')
      end
    end

    context 'when missing project id' do
      before do
        allow(Lita.config.handlers.kanban).to receive(:pivotal_tracker_token).and_return('token')
        allow(Lita.config.handlers.kanban).to receive(:pivotal_tracker_project_id).and_return(nil)
        allow_any_instance_of(TrackerApi::Client).to receive(:project).and_return(nil)
      end

      it 'raise an error' do
        expect { send_command("kanban #{after_story_id} #{before_story_id}") }.to raise_error('Missing Pivotal Tracker project id')
      end
    end

    context 'when found stories' do
      before do
        allow_any_instance_of(Lita::Handlers::Kanban).to receive(:stories).and_return(
          [
            TrackerApi::Resources::Story.new(id: 1, name: "story1"),
            TrackerApi::Resources::Story.new(id: 2, name: "story2")
          ]
        )
      end

      it 'return stories' do
        send_command("kanban #{after_story_id} #{before_story_id}")
        expect(replies.last).to eq "story1\nstory2"
      end
    end

    context 'when not found stories' do
      before do
        allow_any_instance_of(Lita::Handlers::Kanban).to receive(:stories).and_return(
          [
          ]
        )
      end

      it 'return stories' do
        send_command("kanban #{after_story_id} #{before_story_id}")
        expect(replies.last).to eq ""
      end
    end
  end
end
