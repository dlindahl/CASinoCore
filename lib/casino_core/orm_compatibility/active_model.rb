# ActiveModel ORM-Compatibility Layer
#
# This mixin provides support for ORMs that are known to support the ActiveModel
# interface.
#
# To add CASinoCore ORM-compatibility to your own ORM, simply extend
# your base class with CASinoCore::OrmCompatibility::ActiveModel
#
# While it would be great to provide compatiblity with all implementors of the
# ActiveModel interface, it is not currently possible as ActiveModel does not
# provide a base class that is then inherited from. Each compatible ORM must
# therefore be explicitly added.
module CASinoCore
  module OrmCompatibility
    module ActiveModel

      def include_casino_core_orm_compatibility
        layer = :ActiveModelCompatibility

        if constants.include?(layer)
          include const_get(layer)
        end
      end

    end
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend CASinoCore::OrmCompatibility::ActiveModel
end

if defined?(Mongoid::Document)
  Mongoid::Document::ClassMethods.send :include, CASinoCore::OrmCompatibility::ActiveModel
end