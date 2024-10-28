class Page
  def initialize(file)
    page_txt = File.read(file)

    @header = {}
    # @content = {}
    body = nil

    lines = page_txt.lines
    block_regex = /^---[-]*$/
    comment_regex = /^#.*$/
    in_multiline = false
    multiline = []
    multiline_name = nil
    if lines.first.match? block_regex
      for line, i in lines[1...].each_with_index
        if line.match? block_regex
          body = lines[i+2...].join("")
          @header["body"] = body
          break
        end

        next if line.match? comment_regex

        if line.match? /.*(?<!\\)=.*/
          param = line.split(/(?<!\\)=/)
          if param.count != 2
            raise HTTPError.new(500, "Invalid parameter definition at #{param.inspect}")
          end
          @header[param[0].strip] = param[1].strip
        elsif line.match? /.*(?<!\\)<<EOF.*/
          s = line.split /(?<!\\)<<EOF/
          multiline_name = s[0]
          in_multiline = true
        elsif line.match? /^EOF$/
          next if !in_multiline

          in_multiline = false

          @header[multiline_name.strip] = multiline.join
        else
          if in_multiline
            multiline << line
          else
            raise HTTPError.new(500, "Invalid header line at #{param.inspect}")
          end
        end
      end
    else
      body = page_txt
    end

    raise HTTPError.new(500, "no body") if body == nil

    @template = ERB.new(body)
  end

  def render(layouts, sitedata)
    layout = layouts[@header["layout"] || "base"]

    @header["body"] = @template.result(OpenStruct.new(sitedata).instance_eval { binding })

    return layout.template
      .result(OpenStruct.new(@header.merge(sitedata)).instance_eval { binding })
  end
end
