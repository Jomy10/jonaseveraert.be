class HTTPError < StandardError
  attr_reader :code, :message

  def initialize(code, msg=nil)
    @code = code
    @message = msg
  end
end
