class NYCAAddress < NYUSAddress
  def construct(opts = {})
    opts = {include_unit: true, include_label: true, include_dir: true, include_postal: true}.merge(opts)

    addr = "#{@parts[:street_number]}#{@parts[:street_name]}#{@parts[:city]}#{@parts[:state]}"
    opts[:include_unit] ? addr << @parts[:unit].to_s : nil
    opts[:include_label] ? addr << @parts[:street_label].to_s : nil
    opts[:include_dir] ? addr << @parts[:street_direction].to_s : nil
    opts[:include_postal] ? addr << (@parts[:postal_code] || 'Z9Z 9Z9').to_s : nil
    addr.delete(' ').delete('-').downcase
  end
end
