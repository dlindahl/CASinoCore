require 'spec_helper'

describe CASinoCore::Concerns::User do

  let(:am_model) { TestUser }

  let(:poro_model) do
    Class.new(Poro) do
      include CASinoCore::Concerns::User
    end
  end

  before { stub_const 'Model', model }

  subject(:instance) { Model.new }

  describe '#active_two_factor_authenticators' do
    subject { instance.active_two_factor_authenticators }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      let(:instance) { create :user_with_two_factor_auth, active:true }

      it 'returns the ticket identifier' do
        expect(subject).not_to be_empty
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '#two_factor_authenticator' do
    subject { instance.two_factor_authenticator(1) }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      let(:instance) { create :user_with_two_factor_auth, active:true }

      it 'returns the ticket identifier' do
        expect(subject).to be_an_instance_of CASinoCore.config.implementors[:two_factor_authenticator]
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '#other_ticket_granting_tickets' do
    subject { instance.other_ticket_granting_tickets(1) }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      let(:instance) { create :user_with_ticket_granting_ticket, tickets:2 }

      it 'returns the ticket identifier' do
        expect(subject).to eq [instance.ticket_granting_tickets.last]
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '#authenticated_tickets' do
    subject { instance.authenticated_tickets }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      let(:instance) do
        create(:user_with_ticket_granting_ticket, tickets:2).tap do |user|
          tgt = user.ticket_granting_tickets.last
          tgt.update_attributes(awaiting_two_factor_authentication:true)
        end
      end

      it 'returns the ticket identifier' do
        expect(subject).to eq [instance.ticket_granting_tickets.first]
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '#delete_active_two_factor_authenticators' do
    subject { instance.delete_active_two_factor_authenticators }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      let(:instance) { create :user_with_two_factor_auth, active:true }

      before { instance }

      it 'returns the ticket identifier' do
        expect{subject}.to change{CASinoCore.config.implementors[:two_factor_authenticator].count}.by(-1)
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '#create_two_factor_authenticator!' do
    let(:auth_params) do
      {
        secret: ROTP::Base32.random_base32
      }
    end

    subject { instance.create_two_factor_authenticator!(auth_params) }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      let(:instance) { create :user }

      it 'creates the appropriate authenticators' do
        expect{subject}.to change{CASinoCore.config.implementors[:two_factor_authenticator].count}.by(1)
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '#create_ticket_granting_ticket!' do
    let(:ticket_params) do
      {
        ticket: 'TGC-123',
        awaiting_two_factor_authentication: true,
        user_agent: 'UserAgent',
        long_term: false
      }
    end

    subject { instance.create_ticket_granting_ticket!(ticket_params) }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      let(:instance) { create :user }

      it 'creates the appropriate ticket' do
        expect{subject}.to change{CASinoCore.implementor(:ticket_granting_ticket).count}.by(1)
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '.load_or_initialize' do
    subject { Model.load_or_initialize username:'jdoe' }

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