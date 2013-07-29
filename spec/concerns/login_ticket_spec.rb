require 'spec_helper'

describe CASinoCore::Concerns::LoginTicket do
  let(:ticket) { 'LT-12345' }

  let(:am_model) { TestLoginTicket }

  let(:poro_model) do
    Class.new(Poro) do
      include CASinoCore::Concerns::LoginTicket
    end
  end

  before { stub_const 'Model', model }

  subject(:instance) { Model.new ticket:ticket }

  describe '.cleanup' do
    subject { Model.cleanup }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      before { create :login_ticket, :expired }

      it 'deletes expired login tickets' do
        expect{subject}.to change{CASinoCore.implementor(:login_ticket).count}.by(-1)
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '#to_s' do
    subject { super().to_s }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      it 'returns the ticket identifier' do
        expect(subject).to eq instance.ticket
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NoMethodError, %r{undefined method `ticket'}
      end
    end
  end
end
