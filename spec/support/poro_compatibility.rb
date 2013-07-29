class Poro
  def initialize(*args)
  end
end

module CASinoCore
  module OrmCompatibility
    module PoroCompatibility

      def include_casino_core_orm_compatibility
      end

    end
  end
end

Poro.extend CASinoCore::OrmCompatibility::PoroCompatibility