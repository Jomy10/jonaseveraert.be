class PageDefinition
  attr_reader :parameters, :body

  def initialize(definition)
    if definition == "" || definition == nil
      raise 500
    end

    lines = definition.lines.filter {  |l| l.strip != "" && !l.start_with?("#") }
    if (lines.first =~ /---.*/) != nil
      # Collect parameters
      parameters = []
      for line, i in lines[1...].each_with_index
        if (line =~ /---.*/) != nil
          @body = lines[i+2...].join("")
          break
        end
        parameters << line
      end
      if @body == nil
        raise 500
      end

      # Parse parameters
      @parameters = parameters.map do |parameter|
        parameter.split('=', 2).map { |v| v.strip }
      end.to_h
    else
      @body = definition
    end
  end
end
