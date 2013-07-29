require 'spec_helper'

describe CASinoCore::Concerns::ProxyGrantingTicket do
  let(:am_model) { TestProxyTicket }

  let(:poro_model) do
    Class.new(Poro) do
      include CASinoCore::Concerns::ProxyGrantingTicket
    end
  end

  before { stub_const 'Model', model }

  subject(:instance) { Model.new }

  describe '#create_proxy_ticket!' do
    let(:ticket_params) do
      {
          ticket: 'PT-123',
          service: 'http://example.com'
      }
    end

    subject { instance.create_proxy_ticket!(ticket_params) }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      let(:instance) { create :proxy_granting_ticket }

      it 'creates the appropriate tickets' do
        expect{subject}.to change{CASinoCore.implementor(:proxy_ticket).count}.by(1)
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