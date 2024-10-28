class Component
  def initialize(file)
    raise HTTPError.new(500, "Component #{file} does not exist") unless File.exist? file

    component_txt = File.read(file)

    @template = ERB.new(component_txt)
  end

  def render(ostruct_data)
    return @template.result(ostruct_data.instance_eval { binding })
  end
end

class ComponentRenderer
  # - `components`: hash of name => component
  def initialize(components, data)
    @components = components
    @data = OpenStruct.new(data)
  end

  def render(name, extra_data = nil)
    component = @components[name]
    raise HTTPError.new(500, "Component #{name} does not exist") if component.nil?

    if extra_data.nil?
      return component.render(@data)
    else
      return component.render(@data.merge(extra_data))
    end
  end
end
