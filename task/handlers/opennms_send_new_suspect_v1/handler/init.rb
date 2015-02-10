require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class OpennmsSendNewSuspectV1
  def initialize(input)
    # Set the input document.
    @input_document = REXML::Document.new input
    @debugging_enabled = false

    # Store the info values in a Hash of info names => values.
    @info_values = Hash.new
    REXML::XPath.each(@input_document,'/handler/infos/info') do |item|
      @info_values[item.attributes['host']] = item.text
    end
    @debugging_enabled = true if @info_values['enable_debugging'].eql? 'Yes'


    # Retrieve all of the handler parameters and store them in a hash attribute.
    @parameters = Hash.new
    REXML::XPath.match(@input_document,'/handler/parameters/parameter').each do |node|
      # Associate the attribute name to the String value, stripping leading/trailing whitespace.
      @parameters[node.attribute('name').value] = node.text.to_s.strip
    end
  end

  def execute
    opennms_host = @info_values['host']
    interface = @parameters['interface']
    event_source = @parameters['source']
    formatted_time = Time.now.strftime "%A, %m %B %Y %H:%M:%S o'clock %Z"
    hostname = Socket.gethostname

    # Assemble the new suspect event XML.
    event_xml = <<EOF
<log>
  <events>
    <event>
      <uei>uei.opennms.org/internal/discovery/newSuspect</uei>
      <source>#{event_source}</source>
      <time>#{formatted_time}</time>
      <host>#{hostname}</host>
      <interface>#{interface}</interface>
      <host>
    </event>
  </events>
</log>
EOF

    socket = TCPSocket.open opennms_host, 5817
    socket.puts event_xml
    socket.close

  end
end
