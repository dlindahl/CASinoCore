require 'spec_helper'

describe CASinoCore::Processor::TwoFactorAuthenticatorRegistrator do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }
    let(:cookies) { { tgt: tgt } }

    before(:each) do
      listener.stub(:user_not_logged_in)
      listener.stub(:two_factor_authenticator_registered)
    end

    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { create :ticket_granting_ticket }
      let(:user) { ticket_granting_ticket.user }
      let(:tgt) { ticket_granting_ticket.ticket }
      let(:user_agent) { ticket_granting_ticket.user_agent }

      it 'creates exactly one authenticator' do
        lambda do
          processor.process(cookies, user_agent)
        end.should change{CASinoCore.implementor(:two_factor_authenticator).count}.by(1)
      end

      it 'calls #two_factor_authenticator_created on the listener' do
        listener.should_receive(:two_factor_authenticator_registered) do |authenticator|
          authenticator.should == CASinoCore.implementor(:two_factor_authenticator).last
        end
        processor.process(cookies, user_agent)
      end

      it 'creates an inactive two-factor authenticator' do
        processor.process(cookies, user_agent)
        CASinoCore.implementor(:two_factor_authenticator).last.should_not be_active
      end
    end

    context 'with an invalid ticket-granting ticket' do
      let(:tgt) { 'TGT-lalala' }
      let(:user_agent) { 'TestBrowser 1.0' }
      it 'calls the #user_not_logged_in method on the listener' do
        listener.should_receive(:user_not_logged_in).with(no_args)
        processor.process(cookies, user_agent)
      end
    end
  end
end