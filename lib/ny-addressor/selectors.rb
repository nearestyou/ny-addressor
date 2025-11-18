# frozen_string_literal: true
module NYAddressor
  module Selectors
    MIN   = ->(variants) { variants.min_by { |v| [v.length, v] } }
    MAX   = ->(variants) { variants.max_by { |v| [v.length, v] } }
    FIRST = ->(variants) { variants.first }
    LAST  = ->(variants) { variants.last }

    HEURISTIC = ->(variants) do
      Expander.best_variant_by_heuristic(variants)
    end
  end
end
