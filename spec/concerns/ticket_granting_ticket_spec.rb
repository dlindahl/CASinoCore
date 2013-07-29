require 'spec_helper'
require 'useragent'

describe CASinoCore::Concerns::TicketGrantingTicket do
  let(:am_model) { TestTicketGrantingTicket }

  let(:poro_model) do
    Class.new(Poro) do
      include CASinoCore::Concerns::TicketGrantingTicket

      attr_reader :awaiting_two_factor_authentication, :user_agent, :long_term

      def initialize(params = {})
        params.each{|k,v| instance_variable_set("@#{k}",v) }
      end

      def destroy; end
    end
  end

  before { stub_const 'Model', model }

  let(:params) { Hash.new }

  let(:instance) { Model.new params }

  subject { instance }

  describe '#destroy' do
    subject { instance.destroy }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      let(:instance) { create :ticket_granting_ticket, :expired }

      before do
        create :service_ticket_with_proxy_granting_ticket, :consumed, ticket_granting_ticket:instance
      end

      context 'when notification for a service ticket fails' do
        it 'deletes depending proxy-granting tickets' do
          expect{subject}.to change{CASinoCore.implementor(:proxy_granting_ticket).count}.by(-1)
        end

        it 'deletes depending service tickets' do
          expect{subject}.to change{CASinoCore.implementor(:service_ticket).count}.by(-1)
        end
      end
    end
  end

  describe '#browser_info' do
    let(:model) { poro_model }

    let(:browser) { 'TestBrowser' }

    let(:user_agent) do
      double('user_agent', browser:browser, platform:platform)
    end

    let(:params) { { user_agent:browser } }

    subject { super().browser_info }

    before do
      UserAgent.stub(:parse).and_return(user_agent)
    end

    context 'without platform' do
      let(:platform) { nil }

      it 'returns the browser name' do
        expect(subject).to eq 'TestBrowser'
      end
    end

    context 'with a platform' do
      let(:platform) { 'Linux' }

      it 'returns the browser name' do
        expect(subject).to eq 'TestBrowser (Linux)'
      end
    end
  end

  describe '#create_service_ticket!' do
    let(:ticket_params) do
      {
          ticket: 'ST-123',
          service: 'http://example.com',
          issued_from_credentials: false
      }
    end

    subject { instance.create_service_ticket!(ticket_params) }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      let(:instance) { create :ticket_granting_ticket }

      it 'creates the appropriate tickets' do
        expect{subject}.to change{CASinoCore.implementor(:service_ticket).count}.by(1)
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '#same_user?' do
    subject { super().same_user?(other_ticket_granting_ticket) }

    let(:instance) { create :ticket_granting_ticket }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      context 'with a nil value' do
        let(:other_ticket_granting_ticket) { nil }

        it 'should return false' do
          expect(subject).to be_false
        end
      end

      context 'with a ticket from another user' do
        let(:other_ticket_granting_ticket) { create :ticket_granting_ticket  }

        it 'should return false' do
          expect(subject).to be_false
        end
      end

      context 'with a ticket from the same user' do
        let(:other_ticket_granting_ticket) { create :ticket_granting_ticket, user:instance.user }

        it 'should return true' do
          expect(subject).to be_true
        end
      end
    end
  end

  describe '#expired?' do
    subject { instance.expired? }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      let(:traits) { [] }

      let(:instance) { create :ticket_granting_ticket, *traits }

      shared_examples 'expiration scenarios' do
        it { should be_false }

        context 'when expired' do
          let(:traits) { super() + [:expired] }

          it { should be_true }
        end
      end

      include_examples 'expiration scenarios'

      context 'that represents a long-term ticket' do
        let(:traits) { [:long_term] }

        include_examples 'expiration scenarios'
      end

      context 'that represents a ticket pending two-factor authentication' do
        let(:traits) { [:awaiting_two_factor_authentication] }

        include_examples 'expiration scenarios'
      end
    end
  end

  describe '#lifetime' do
    let(:model) { poro_model }

    subject { super().lifetime }

    context 'when consumed' do
      it { should == CASinoCore.config.ticket_granting_ticket[:lifetime] }
    end

    context 'when long-term' do
      let(:params) { { long_term:true } }

      it { should == CASinoCore.config.ticket_granting_ticket[:lifetime_long_term] }
    end

    context 'when awaiting two-factor authentication' do
      let(:params) { { awaiting_two_factor_authentication:true } }

      it { should == CASinoCore.config.two_factor_authenticator[:timeout] }
    end
  end

  describe '.cleanup' do
    let(:user) { nil }

    subject { Model.cleanup(user) }

    context 'with a PORO class' do
      let(:model) { poro_model }

      before do
        Model.stub(:delete_all_expired_tickets)
      end

      it 'deletes the expired tickets' do
        subject

        expect(Model).to have_received(:delete_all_expired_tickets).once.with(Model)
      end

      context 'for a user' do
        let(:user_tickets) { double('user_tickets').as_null_object }
        let(:user) { double('user', ticket_granting_tickets:user_tickets) }

        it 'deletes the user\'s expired tickets' do
          subject

          expect(Model).to have_received(:delete_all_expired_tickets).once.with(user_tickets)
        end
      end
    end
  end

  describe '.delete_expired_two_factor_tickets' do
    subject { Model.delete_expired_two_factor_tickets(Model) }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      before do
        create :ticket_granting_ticket, :expired
        create :ticket_granting_ticket, :long_term, :expired
        create :ticket_granting_ticket, :awaiting_two_factor_authentication, :expired
      end

      it 'deletes the appropriate tickets' do
        expect{subject}.to change{Model.count}.by(-1)
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '.delete_expired_short_term_tickets' do
    subject { Model.delete_expired_short_term_tickets(Model) }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      before do
        create :ticket_granting_ticket, :expired
        create :ticket_granting_ticket, :long_term, :expired
        create :ticket_granting_ticket, :awaiting_two_factor_authentication, :expired
      end

      it 'deletes the appropriate tickets' do
        expect{subject}.to change{Model.count}.by(-1)
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '.delete_expired_long_term_tickets' do
    subject { Model.delete_expired_long_term_tickets(Model) }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      before do
        create :ticket_granting_ticket, :expired
        create :ticket_granting_ticket, :long_term, :expired
        create :ticket_granting_ticket, :awaiting_two_factor_authentication, :expired
      end

      it 'deletes the appropriate tickets' do
        expect{subject}.to change{Model.count}.by(-1)
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '.delete_all_expired_tickets' do
    let(:scope) { double('scope', delete_all:true) }

    subject { Model.delete_all_expired_tickets(scope) }

    let(:model) { poro_model }

    before do
      Model.stub(:delete_expired_two_factor_tickets)
      Model.stub(:delete_expired_short_term_tickets)
      Model.stub(:delete_expired_long_term_tickets)
    end

    it 'calls different deletion strategies' do
      subject

      expect(Model).to have_received(:delete_expired_two_factor_tickets).with(scope)
      expect(Model).to have_received(:delete_expired_short_term_tickets).with(scope)
      expect(Model).to have_received(:delete_expired_long_term_tickets).with(scope)
    end
  end

  describe '.find_ticket' do
    subject { Model.find_ticket('TGT-123') }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      it 'raises an exception' do
        expect{subject}.not_to raise_error
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '.find_id' do
    subject { Model.find_id(1) }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      it 'raises an exception' do
        expect{subject}.not_to raise_error
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end
end