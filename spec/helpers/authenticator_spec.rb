require 'spec_helper'

describe CASinoCore::Helper::Authentication do

  let(:abstract_class) do
    Class.new do
      include CASinoCore::Helper::Authentication
    end
  end

  before do
    stub_const 'Container', abstract_class
  end

  subject { Container.new }

  describe '#authenticators' do
    subject { super().authenticators }

    context 'with an un-instantiated authenticator' do
      before do
        CASinoCore.configure do |cfg|
          cfg.authenticators[:mock] = auth
        end
      end

      context 'that includes an explicit class name' do
        let(:auth) do
          {
            class: 'CASinoCore::Authenticator::Static',
            options: {}
          }
        end

        it 'instantiates them' do
          expect(subject[:mock]).to be_an_instance_of CASinoCore::Authenticator::Static
        end
      end

      context 'that includes a Gem name' do
        let(:auth) do
          {
            authenticator: name,
            options: {}
          }
        end

        let(:name) { 'MockAuthenticator' }

        it 'instantiates them' do
          expect(subject[:mock]).to be_an_instance_of CASinoCore::Authenticator::MockAuthenticator
        end

        context 'that does not exist' do
          let(:name) { 'ActiveRecord' }

          it 'raises a custom LoadError' do
            expect{subject[:mock]}.to raise_error LoadError,
              %r{Failed to load authenticator 'ActiveRecord'. Maybe you have to include "gem 'casino_core-authenticator-active_record'"}
          end
        end

        context 'that is authored with the wrong namespace' do
          before do
            # Returns a fake stub name in order to trigger a constant look-up
            # error. Its either this, or stub out `require`...
            Container.any_instance.stub(:parse_name).and_return [
              "casino_core-authenticator-#{name.underscore}",
              "NonExistantConst"
            ]
          end

          it 'raises a custom NameError' do
            expect{subject[:mock]}.to raise_error NameError,
              %r{Failed to load authenticator 'MockAuthenticator'. The authenticator class must be defined in the CASinoCore::Authenticator namespace.}
          end
        end
      end

    end
  end

end