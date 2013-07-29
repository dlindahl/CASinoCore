require 'spec_helper'

describe CASinoCore::Processor::API::Logout do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }

    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { create(:ticket_granting_ticket) }
      let(:user_agent) { ticket_granting_ticket.user_agent }

      it 'deletes the ticket-granting ticket' do
        listener.should_receive(:user_logged_out_via_api)
        processor.process(ticket_granting_ticket.ticket, user_agent)
        CASinoCore.implementor(:ticket_granting_ticket).find_id(ticket_granting_ticket.id).should == nil
      end

      it 'calls the #user_logged_out_via_api method on the listener' do
        listener.should_receive(:user_logged_out_via_api)
        processor.process(ticket_granting_ticket, user_agent)
      end

    end

    context 'with an invalid ticket-granting ticket' do
      let(:tgt) { 'TGT-lalala' }

      it 'calls the #user_logged_out method on the listener' do
        listener.should_receive(:user_logged_out_via_api)
        processor.process(tgt)
      end
    end
  end
end
