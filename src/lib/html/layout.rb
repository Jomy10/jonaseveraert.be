require 'ostruct'

class Layout
  attr_reader :template

  def initialize(page)
    @template = ERB.new File.read(page)
  end
end
