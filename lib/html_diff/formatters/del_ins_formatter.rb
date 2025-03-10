# frozen_string_literal: true

require_relative 'generic_formatter'

module HTMLDiff
  module Formatters
    # The DelInsFormatter renders the diff as HTML with <del> and <ins> tags.
    module DelInsFormatter
      extend self

      # Format a sequence of changes from LcsDiff into HTML
      #
      # @param changes [Array<Array>] Array of [action, old_string, new_string] tuples,
      #   where action is one of '=' (equal), '-' (remove), '+' (add), or '!' (replace)
      # @return [String] HTML formatted diff
      def format(changes)
        GenericFormatter.format(changes, class_delete: 'diffdel', class_insert: 'diffins', class_replace: 'diffmod')
      end
    end
  end
end
