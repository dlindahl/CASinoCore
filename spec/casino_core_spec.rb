require 'spec_helper'

describe CASinoCore do

  it 'applies default values' do
    expect(described_class.config.service_ticket[:lifetime_consumed]).to_not be_nil
  end

  describe '.env' do
    it 'defaults to a non-nil value' do
      expect(described_class.env).to_not be_nil
    end
  end

  describe '.env=' do
    before do
      @env = described_class.env

      described_class.env = 'foo'
    end

    it 'stores an ActiveSupport::StringInquirer instance' do
      expect(described_class.env).to be_an_instance_of ActiveSupport::StringInquirer
    end

    after { described_class.env = @env }
  end

  describe '.apply_yaml_config' do
    let(:yaml) do
      <<-END_OF_YAML
        test:
          service_ticket:
            lifetime_unconsumed: 299
            foo: bar
          new_key: new_value
      END_OF_YAML
    end

    before do
      described_class.apply_yaml_config yaml
    end

    subject { described_class.config }

    it 'merges in the YAML-encoded config values' do
      expect(subject.service_ticket[:lifetime_unconsumed]).to eq 299
      expect(subject.service_ticket[:foo]).to eq 'bar'
      expect(subject[:new_key]).to eq 'new_value'
    end
  end

  describe '.setup' do
    before { described_class.setup 'DEV', application_root:'/foo/bar'}

    it 'sets the application_root' do
      expect(described_class.config.application_root).to eq '/foo/bar'
    end

    it 'sets the environment' do
      expect(described_class.env).to eq 'DEV'
    end
  end

  # describe '.config' do
  #   before do
  #     CASinoCore.setup
  #   end

  #   it 'foo' do
  #     CASinoCore.config
  #   end
  # end
end