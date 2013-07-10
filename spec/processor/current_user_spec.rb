require 'spec_helper'

describe CASinoCore::Processor::CurrentUser do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }
    let(:user) { FactoryGirl.create :user }
    let(:user_agent) { ticket_granting_ticket.user_agent }
    let(:cookies) { { tgt: tgt } }

    before(:each) do
      listener.stub(:user_not_logged_in)
      listener.stub(:current_user)
    end

    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket, user: user }
      let(:tgt) { ticket_granting_ticket.ticket }
      it 'calls the #current_user method on the listener' do
        listener.should_receive(:current_user).with(user)
        processor.process(cookies, user_agent)
      end
    end

    context 'with a ticket-granting ticket with same username but different authenticator' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
      let(:tgt) { ticket_granting_ticket.ticket }
      it 'calls the #current_user method on the listener' do
        listener.should_receive(:current_user).with(ticket_granting_ticket.user) do |current_user|
          current_user != user
        end
        processor.process(cookies, user_agent)
      end
    end

    context 'with an invalid ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
      let(:tgt) { 'TGT-lalala' }
      it 'calls the #user_not_logged_in method on the listener' do
        listener.should_receive(:user_not_logged_in).with(no_args)
        processor.process(cookies, user_agent)
      end
    end
  end
end