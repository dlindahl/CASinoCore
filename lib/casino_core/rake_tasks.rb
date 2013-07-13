module CASinoCore
  class RakeTasks
    class << self
      def load_tasks
        %w(
          cleanup
          service_rule
        ).each do |task|
          load "casino_core/tasks/#{task}.rake"
        end
      end
    end
  end
end
