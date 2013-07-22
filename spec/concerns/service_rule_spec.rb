require 'spec_helper'

describe CASinoCore::Concerns::ServiceRule do
  let(:am_model) { TestServiceRule }

  let(:poro_model) do
    Class.new(Poro) do
      include CASinoCore::Concerns::ServiceRule
    end
  end

  before { stub_const 'Model', model }

  subject(:instance) { Model.new }

  describe '.allowed?' do
    subject { Model.allowed?(service_url) }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      context 'and no defined rules' do
        let(:service_url) { 'there_are_no_rules!' }

        it 'allows anything' do
          expect(subject).to be_true
        end
      end

      context 'and a SSL-only Regex rule' do
        before do
          create :service_rule, :regex, url: '^https://.*'
        end

        context 'and an SSL-based Service URL' do
          let(:service_url) { 'https://www.google.com/' }

          it 'is allowed' do
            expect(subject).to be_true
          end
        end

        context 'and an insecure Service URL' do
          let(:service_url) { 'http://www.example.org/' }

          it 'is denied' do
            expect(subject).to be_false
          end
        end
      end

      context 'with many Regex rules' do
        before do
          100.times do |counter|
            create :service_rule, :regex, url: "^https://www#{counter}.example.com"
          end
        end

        let(:service_url) { 'https://www111.example.com/bla' }

        # NOTE: Not sure this is a useful test. Seems to test ORM access speed
        # rather than something specific to CASinoCore
        it 'does not take too long to check a denied service' do
          expect{subject}.to take_less_than(0.1).seconds
        end
      end

      context 'with a non-Regex rule' do
        before do
          create :service_rule, url: 'https://www.google.com/foo'
        end

        context 'and a matching Service URL' do
          let(:service_url) { 'https://www.google.com/foo' }

          it 'is allowed' do
            expect(subject).to be_true
          end
        end

        context 'and a non-matching Service URL' do
          let(:service_url) { 'https://www.google.com/test' }

          it 'is denied' do
            expect(subject).to be_false
          end
        end
      end
    end

    context 'with a PORO class' do
      let(:model) { poro_model }

      let(:service_url) { 'dummy_url' }

      it 'raises an exception' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end
end