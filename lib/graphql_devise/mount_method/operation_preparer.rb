# frozen_string_literal: true

require_relative 'operation_preparers/gql_name_setter'
require_relative 'operation_preparers/mutation_field_setter'
require_relative 'operation_preparers/resolver_type_setter'
require_relative 'operation_preparers/resource_name_setter'
require_relative 'operation_preparers/default_operation_preparer'
require_relative 'operation_preparers/custom_operation_preparer'

module GraphqlDevise
  module MountMethod
    class OperationPreparer
      def initialize(mapping_name:, selected_operations:, preparer:, custom:, additional_operations:)
        @selected_operations   = selected_operations
        @preparer              = preparer
        @mapping_name          = mapping_name
        @custom                = custom
        @additional_operations = additional_operations
      end

      def call
        default_operations = OperationPreparers::DefaultOperationPreparer.new(
          selected_operations: @selected_operations,
          custom_keys:         @custom.keys,
          mapping_name:        @mapping_name,
          preparer:            @preparer
        ).call

        custom_operations = OperationPreparers::CustomOperationPreparer.new(
          selected_keys:     @selected_operations.keys,
          custom_operations: @custom,
          mapping_name:      @mapping_name
        ).call

        additional_operations = @additional_operations.each_with_object({}) do |(action, operation), result|
          result[action] = OperationPreparers::ResourceNameSetter.new(@mapping_name).call(operation)
        end

        default_operations.merge(custom_operations).merge(additional_operations)
      end
    end
  end
end
