require 'spec_helper'

describe CASinoCore::Processor::LoginCredentialAcceptor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }
    let(:password) { 'foobar123' }
    let(:authenticator) do
      CASinoCore::Authenticator::Static.new(
        users: {
          testuser: {
            password: password,
            name: 'Test User'
          }
        }
      )
    end

    before do
      CASinoCore.configure do |cfg|
        cfg.authenticators[:static] = authenticator
        cfg.implementors[:login_ticket] = TestLoginTicket
      end
    end

    context 'without a valid login ticket' do
      it 'calls the #invalid_login_ticket method on the listener' do
        listener.should_receive(:invalid_login_ticket).with(kind_of(CASinoCore.implementor(:login_ticket)))
        processor.process
      end
    end

    context 'with an expired login ticket' do
      let(:expired_login_ticket) { create :login_ticket, :expired }

      it 'calls the #invalid_login_ticket method on the listener' do
        listener.should_receive(:invalid_login_ticket).with(kind_of(CASinoCore.implementor(:login_ticket)))
        processor.process(lt: expired_login_ticket.ticket)
      end
    end

    context 'with a valid login ticket' do
      let(:login_ticket) { FactoryGirl.create :login_ticket }

      context 'with invalid credentials' do
        it 'calls the #invalid_login_credentials method on the listener' do
          listener.should_receive(:invalid_login_credentials).with(kind_of(CASinoCore.implementor(:login_ticket)))
          processor.process(lt: login_ticket.ticket)
        end
      end

      context 'with valid credentials' do
        let(:service) { 'https://www.example.org' }
        let(:username) { 'testuser' }
        let(:login_data) { { lt: login_ticket.ticket, username: username, password:password, service: service } }

        before(:each) do
          listener.stub(:user_logged_in)
        end

        context 'with rememberMe set' do
          let(:login_data_with_remember_me) { login_data.merge(rememberMe: true) }

          it 'calls the #user_logged_in method on the listener with an expiration date set' do
            listener.should_receive(:user_logged_in).with(/^#{service}\/\?ticket=ST\-/, /^TGC\-/, kind_of(Time))
            processor.process(login_data_with_remember_me)
          end

          it 'creates a long-term ticket-granting ticket' do
            processor.process(login_data_with_remember_me)
            tgt = CASinoCore.implementor(:ticket_granting_ticket).last
            tgt.long_term.should == true
          end
        end

        context 'with two-factor authentication enabled' do
          let(:user) { CASinoCore::Model::User.create! username: username, authenticator:'static' }
          let!(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, user: user }

          it 'calls the `#two_factor_authentication_pending` method on the listener' do
            listener.should_receive(:two_factor_authentication_pending).with(/^TGC\-/)
            processor.process(login_data)
          end
        end

        context 'with a not allowed service' do
          before(:each) do
            FactoryGirl.create :service_rule, :regex, url: '^https://.*'
          end
          let(:service) { 'http://www.example.org/' }

          it 'calls the #service_not_allowed method on the listener' do
            listener.should_receive(:service_not_allowed).with(service)
            processor.process(login_data)
          end
        end

        context 'when all authenticators raise an error' do
          before(:each) do
            CASinoCore::Authenticator::Static.any_instance.stub(:validate) do
              raise CASinoCore::Authenticator::AuthenticatorError, 'error123'
            end
          end

          it 'calls the #invalid_login_credentials method on the listener' do
            listener.should_receive(:invalid_login_credentials).with(kind_of(CASinoCore.implementor(:login_ticket)))
            processor.process(login_data)
          end
        end

        context 'without a service' do
          let(:service) { nil }

          it 'calls the #user_logged_in method on the listener' do
            listener.should_receive(:user_logged_in).with(nil, /^TGC\-/)
            processor.process(login_data)
          end

          it 'generates a ticket-granting ticket' do
            lambda do
              processor.process(login_data)
            end.should change{CASinoCore.implementor(:ticket_granting_ticket).count}.by(1)
          end

          context 'when the user does not exist yet' do
            it 'generates exactly one user' do
              lambda do
                processor.process(login_data)
              end.should change(CASinoCore::Model::User, :count).by(1)
            end

            it 'sets the users attributes' do
              processor.process(login_data)
              user = CASinoCore::Model::User.last
              user.username.should == username
              user.authenticator.should == 'static'
            end
          end

          context 'when the user already exists' do
            it 'does not regenerate the user' do
              CASinoCore::Model::User.create! username: username, authenticator:'static'
              lambda do
                processor.process(login_data)
              end.should_not change(CASinoCore::Model::User, :count)
            end

            it 'updates the extra attributes' do
              user = CASinoCore::Model::User.create! username: username, authenticator:'static'
              lambda do
                processor.process(login_data)
                user.reload
              end.should change(user, :extra_attributes)
            end
          end
        end

        context 'with a service' do
          let(:service) { 'https://www.example.com' }

          it 'calls the #user_logged_in method on the listener' do
            listener.should_receive(:user_logged_in).with(/^#{service}\/\?ticket=ST\-/, /^TGC\-/)
            processor.process(login_data)
          end

          it 'generates a service ticket' do
            lambda do
              processor.process(login_data)
            end.should change{CASinoCore.implementor(:service_ticket).count}.by(1)
          end

          it 'generates a ticket-granting ticket' do
            lambda do
              processor.process(login_data)
            end.should change{CASinoCore.implementor(:ticket_granting_ticket).count}.by(1)
          end
        end
      end
    end
  end
end
