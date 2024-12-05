module NYAddressor
  class AddressPart
    attr_reader :from_pattern, :from_position, :from_comma, :from_all
    attr_reader :text, :position, :group, :group_position

    # Initializes a new address part
    # @param text [String] substring of the address
    # @param position [Integer] The word index of the substring within the full address
    # @param group [Integer] The index of the comma-separated group this substring resides in
    # @param group_position [Integer] Which comma separated block the substring resides in
    def initialize(text, position, group, group_position)
      @text = text
      @group = group
      @group_position = group_position
      @position = position
    end

    def consolidate_options
      @from_all = @from_pattern
      @from_all &= @from_position if @from_position
      @from_all &= @from_comma if @from_comma
    end
  end
end
