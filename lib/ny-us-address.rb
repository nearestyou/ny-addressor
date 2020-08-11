require 'digest'
#require 'byebug'
#load 'lib/constants.rb'
#load 'lib/identifier.rb'

class NYUSAddress
  attr_accessor :monitor, :str, :orig, :typified, :sep, :bus, :sep_map, :sep_comma, :idr, :parts

  def initialize(str)
    @monitor = false
    if not str.nil?
      @orig = str # to keep an original
      @str = str
      @idr = USIdentifier.new(self)
      identify
    end
  end

  def identify
    identification = @idr.identifications
    @sep = identification[:sep]
    @sep_map = identification[:sep_map]
    @sep_comma = identification[:sep_comma]
    @bus = identification[:sep_map]
    @locale = identification[:locale]
    @parts = identification[:parts]
  end
