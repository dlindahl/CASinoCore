RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run focus: true
  config.order = 'random'
end

# From http://stackoverflow.com/questions/8485369/how-can-i-set-up-rspec-for-performance-testing-on-the-side
require 'benchmark'
RSpec::Matchers.define :take_less_than do |n|
  chain :seconds do; end
  match do |block|
    Benchmark.realtime { block.call } <= n
  end
end