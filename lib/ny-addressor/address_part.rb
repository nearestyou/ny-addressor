module NYAddressor
  class AddressPart
    attr_reader :from_pattern, :from_position, :from_comma, :from_all
    attr_reader :text, :position, :group, :group_position
    attr_reader :confirmed

    # Initializes a new address part
    # @param text [String] substring of the address
    # @param position [Integer] The word index of the substring within the full address
    # @param group [Integer] The index of the comma-separated group this substring resides in
    # @param group_position [Integer] Which comma separated block the substring resides in
    def initialize(text, position, group, group_position)
      @original = text
      @text = text
      @group = group
      @group_position = group_position
      @position = position

      @from_pattern = []
      @from_position = []
      @from_comma = []
      @from_all = []
      @confirmed = nil
    end

    def set_text str
      @text = str
    end

    def to_s
      @text
    end

    def confirm(sym)
      @confirmed = sym
    end

    def debug
      output = "Address Part(#{@text}):"
      output += "\n\tConfirmed: #{@confirmed}"
      output += "\n\tAll: #{@from_all}" if @from_all
      output += "\n\tPositional: #{@from_position}" if @from_position
      output += "\n\tPaternal: #{@from_pattern}" if @from_pattern
      output += "\n\tComma: #{@from_comma}" if @from_comma
      output
    end

    def consolidate_options
      @from_all = @from_pattern
      @from_all &= @from_position if @from_position
      @from_all &= @from_comma if @from_comma
    end

    # Hypothesizes what the part could mean based on it's position
    # @param checker [Proc] A callable object that returns a list 
    # of symbols to describe the parts position
    def determine_position(checker)
      @from_position = checker.call(self)
    end

    def determine_comma_position(checker)
      @from_comma = checker.call(self)
    end

    # Determines if the part matches a specific pattern
    # @param pattern [Symbol] The type of pattern to check
    # @param checker [Proc] A callable object to perform the check
    def determine_pattern(pattern, checker)
      @from_pattern << pattern if checker.call(self)
    end
  end
end
