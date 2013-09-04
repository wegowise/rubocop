# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks that hash keys are either all in one line,
      # or that they are vertically aligned.
      #
      # A separate offence is registered for each problematic pair.
      class AlignHashKeys < Cop
        ALIGNMENT_MSG = 'Hash key is not vertically aligned'
        INCONSISTENT_SYNTAX_MSG = 'Hash has more than one key/ value pair'\
                                  'per line over multiple lines'

        def on_hash(node)
          pairs = *node

          return unless pairs.size > 1

          pair_lines = pairs.map { |p| p.loc.expression.line }
          unique_lines = pair_lines.uniq

          return if unique_lines.size == 1

          if unique_lines.length != pair_lines.length
            pairs.each_with_index do |pair, index|
              next if index == 0
              prev_line = pairs[index - 1].loc.expression.line
              this_line = pair.loc.expression.line

              if prev_line == this_line
                convention(nil,
                           pair.loc.expression.begin.join(pair.loc.operator),
                           INCONSISTENT_SYNTAX_MSG)
                offences.last.needs_newline = true
              end
            end
          else
            first_col = pairs.first.loc.expression.column

            pairs.each do |pair|
              if pair.loc.expression.column != first_col
                difference = first_col - pair.loc.expression.column
                convention(nil,
                           pair.loc.expression.begin.join(pair.loc.operator),
                           ALIGNMENT_MSG)

                offences.last.n_missing_spaces = difference
              end
            end
          end
        end
      end
    end
  end
end


