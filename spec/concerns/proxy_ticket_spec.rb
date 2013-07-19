require 'spec_helper'

describe CASinoCore::Concerns::ProxyTicket do
  let(:am_model) { TestProxyTicket }

  let(:poro_model) do
    Class.new(Poro) do
      include CASinoCore::Concerns::ProxyTicket

      attr_reader :consumed

      def initialize(params = {})
        params.each{|k,v| instance_variable_set("@#{k}",v) }
      end
    end
  end

  before { stub_const 'Model', model }

  let(:params) { Hash.new }

  let(:unconsumed_ticket) { create :proxy_ticket }

  let(:expired_unconsumed_ticket) { create :proxy_ticket, :expired }

  let(:consumed_ticket) { create :proxy_ticket, :consumed }

  let(:expired_consumed_ticket) { create :proxy_ticket, :consumed, :expired }

  subject { Model.new params }

  describe '#expired?' do
    subject { instance.expired? }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      context 'and an unconsumed ticket' do
        context 'that is expired' do
          let(:instance) { expired_unconsumed_ticket }

          it { should be_true }
        end

        context 'that is not expired' do
          let(:instance) { unconsumed_ticket }

          it { should be_false }
        end
      end

      context 'and a consumed ticket' do
        context 'that is expired' do
          let(:instance) { expired_consumed_ticket }

          it { should be_true }
        end

        context 'that is not expired' do
          let(:instance) { consumed_ticket }

          it { should be_false }
        end
      end
    end
  end

  describe '#lifetime' do
    let(:model) { poro_model }

    let(:params) { { consumed:consumed } }

    subject { super().lifetime }

    context 'when consumed' do
      let(:consumed) { true }

      it { should == CASinoCore.config.proxy_ticket[:lifetime_consumed] }
    end

    context 'when unconsumed' do
      let(:consumed) { false }

      it { should == CASinoCore.config.proxy_ticket[:lifetime_unconsumed] }
    end
  end

  describe '.cleanup_unconsumed' do
    subject { Model.cleanup_unconsumed }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      before do
        create :proxy_ticket, :consumed, :expired
        create :proxy_ticket, :expired
      end

      it 'deletes expired unconsumed proxy tickets' do
        expect{subject}.to change{CASinoCore.implementor(:proxy_ticket).count}.by(-1)
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '.cleanup_consumed' do
    subject { Model.cleanup_consumed }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      before do
        create :proxy_ticket, :consumed, :expired
        create :proxy_ticket, :expired
      end

      it 'deletes expired unconsumed proxy tickets' do
        expect{subject}.to change{CASinoCore.implementor(:proxy_ticket).count}.by(-1)
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '.find_ticket' do
    subject { Model.find_ticket('PT-123') }

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an error' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end
end