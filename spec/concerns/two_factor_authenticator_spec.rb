require 'spec_helper'

describe CASinoCore::Concerns::TwoFactorAuthenticator do
  let(:am_model) { TestTwoFactorAuthenticator }

  let(:poro_model) do
    Class.new(Poro) do
      include CASinoCore::Concerns::TwoFactorAuthenticator
    end
  end

  before { stub_const 'Model', model }

  subject(:instance) { Model.new }

  describe '.cleanup' do
    subject { Model.cleanup }

    context 'with an ActiveModel-compatible class' do
      let(:model) { am_model }

      before do
        create :two_factor_authenticator, :expired
        create :two_factor_authenticator, :inactive
        create :two_factor_authenticator, :inactive, :expired
      end

      it 'only deletes expired, inactive two-factor authenticators' do
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
end
