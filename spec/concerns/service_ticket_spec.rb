require 'spec_helper'

describe CASinoCore::Concerns::ServiceTicket do
  let(:am_model) { TestServiceTicket }

  let(:poro_model) do
    Class.new(Poro) do
      include CASinoCore::Concerns::ServiceTicket

      attr_reader :consumed

      def initialize(params = {})
        params.each{|k,v| instance_variable_set("@#{k}",v) }
      end
    end
  end

  let(:params) { Hash.new }

  before { stub_const 'Model', model }

  subject { Model.new params }

  let(:consumed_ticket) { create :service_ticket, :consumed }

  let(:expired_consumed_ticket) { create :service_ticket, :consumed, :expired }

  let(:unconsumed_ticket) { create :service_ticket }

  let(:expired_unconsumed_ticket) { create :service_ticket, :expired }

  describe '#expired?' do
    subject { instance.expired? }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      context 'with a consumed ticket' do
        let(:instance) { consumed_ticket }

        it { should be_false }

        context 'that has expired' do
          let(:instance) { expired_consumed_ticket }

          it { should be_true }
        end
      end

      context 'with an unconsumed ticket' do
        let(:instance) { unconsumed_ticket }

        it { should be_false }

        context 'that has expired' do
          let(:instance) { expired_unconsumed_ticket }

          it { should be_true }
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

      it { should == CASinoCore.config.service_ticket[:lifetime_consumed] }
    end

    context 'when unconsumed' do
      let(:consumed) { false }

      it { should == CASinoCore.config.service_ticket[:lifetime_unconsumed] }
    end
  end

  describe '#sso_notifier' do
    let(:model) { poro_model }

    subject { super().sso_notifier }

    it { should be_an_instance_of CASinoCore::Notifiers::SingleSignOutNotifier }
  end

  describe '#send_sso_notification' do
    let(:notified) { true }

    subject { instance.send_sso_notification }

    before do
      CASinoCore.config.sso_notifications = true
      instance.stub(:sso_notifier).and_return double('sso', notify:notified)
    end

    after { CASinoCore.config.sso_notifications = false }

    shared_examples 'a sent SSO notification' do
      it 'should send the notification' do
        subject

        expect(instance.sso_notifier).to have_received(:notify)
      end

      context 'when notification fails' do
        let(:notified) { false }

        it { should be_true }
      end
    end

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      let(:instance) { consumed_ticket }

      it_behaves_like 'a sent SSO notification'
    end

    context 'with a PORO class' do
      let(:model) { am_model }

      let(:instance) { Model.new }

      it_behaves_like 'a sent SSO notification'
    end
  end

  describe '.cleanup_unconsumed' do
    subject { Model.cleanup_unconsumed }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      before do
        create :service_ticket, :expired
        create :service_ticket, :consumed, :expired
      end

      it 'deletes expired unconsumed tickets' do
        expect{subject}.to change{CASinoCore.implementor(:service_ticket).count}.by(-1)
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an error' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '.cleanup_consumed' do
    let(:force) { nil }

    subject { Model.cleanup_consumed(force) }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      before do
        create :service_ticket, :expired
        create :service_ticket, :consumed, :expired
        create :service_ticket, :orphan, :consumed

        Model.stub(:delete_all_ticket_orphans).and_call_original
      end

      it 'deletes orphaned and expired consumed tickets' do
        expect{subject}.to change{CASinoCore.implementor(:service_ticket).count}.by(-2)
        expect(Model).to have_received(:delete_all_ticket_orphans)
      end

      context 'and forcing deletion' do
        let(:force) { :force }

        before do
          create :service_ticket, :consumed, created_at:10.days.ago
        end

        it 'deletes all expired consumed tickets with an unreachable Single Sign Out callback server' do
          expect{subject}.to change{CASinoCore.implementor(:service_ticket).count}.by(-1)
          expect(Model).to_not have_received(:delete_all_ticket_orphans)
        end
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an error' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '#destroy' do
    subject { instance.destroy }

    before do
      instance.stub(:sso_notifier).and_return double('sso', notify:true)
    end

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      let(:instance) { consumed_ticket }

      it 'sends out a single sign out notification' do
        subject

        expect(instance.sso_notifier).to have_received(:notify)
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      let(:instance) { Model.new }

      it 'raises an error' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end

  describe '.find_ticket' do
    subject { Model.find_ticket('ST-123') }

    context 'with a PORO class' do
      let(:model) { poro_model }

      it 'raises an error' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end
end