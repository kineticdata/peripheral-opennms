module KineticTask
  module Consumers
    class OpenNMSConsumer
      VERSION = "1.0.0"
      # Specify the source name
      SOURCE_NAME ||= "OpenNMS"

      # Register the OpenNMSConsumer with the Base consumer so that it is accessible by the Engine.
      KineticTask::Consumer::Base.register "OpenNMS", self

      # Stores the initial hash used to configure the adapter
      attr_accessor :spec

      def initialize(spec={})
        # Store the spec
        @spec = spec
      end

      #########################################################################
      # CLASS METHODS
      #########################################################################

      # Returns an Array of Hash objects that define what properties are
      # configurable for this consumer (IE: Server, Username, Password, Port, Web Server).
      def self.configurable_properties
        [] # can put properties like handler info values
      end

      # Indicates whether this consumer allows multiple source instances
      def self.allows_multiple_sources
        true # should stay true most likely
      end

      # source_data_label and source_data_description describe source data (aka when clicking run
      # tree form)
      def self.source_data_label
        "OpenNMS JSON Parameters"
      end
      def self.source_data_description
        "The source data for OpenNMS is a JSON string that contains info about a commit."
      end

      #########################################################################
      # INSTANCE METHODS
      #########################################################################

      # Given the source group of a Kinetic Request catalog and template name,
      # build the map of bindable variables that defines the Task Builder node
      # parameter menu.
      def retrieve_binding_definition(source_group)
        # Return the application bindings map
        {
          'Notification' => {
            'Node ID' => '<%=@notification["nodeid"]%>',
            'Message' => '<%=@notification["message"]%>'
          }
        }
      end

      # Given a source group and source id, this consumer builds up the data
      # necessary to process a task tree triggered by that source record.
      def build_bindings(source_group, source_id, source_data=nil)
        # Initialize the bindings hash
        bindings = {}

        # Convert the source data (json string) to a hash
        data = JSON.parse(source_data)

        # Initialize the 'sms' binding variable
        bindings['notification'] = {}

        ### Populating node ID and message.
        ['nodeid','message'].each do |field|
          bindings['notification'][field] = data[field];
        end

        # Return the bindings hash
        bindings
      end

      def retrieve_source_details(source_group, submission_id)
      end

      def retrieve_source_id(source_group, submission_id)
      end

      # Returns a hash that defines the following values:  source_data and source_id.  This
      # particular handler simply sets the source data to the a hash of the request parameters
      # that was passed to the api call and gets the nodeid property from the posted json data
      # to use as the source id.
      def run_tree_handler(bodyContent, httpRequest)
        data = httpRequest.getParameterMap

        source_data = {
          "nodeid" => data.get("nodeid")[0],
          "message" => data.get("message")[0]
        }

        # Check that the source data contains the value we are using for the source id.
        if data["nodeid"].nil?
          raise "The source data did not contain the expected .nodeid property"
        end

        # Return the source_data and source_id. Task expects that source_data is a
        # string, so we'll compact the hash into JSON.
        {
          "source_data" => JSON.generate(source_data),
          "source_id"   => data.get("nodeid")[0]
        }
      end

      # Returns a hash that defines the following values:  token and message.  For this consumer we
      # raise an error because it does not support updating deferred tasks.
      def update_deferred_task_handler(bodyContent, httpRequest)
        raise "The update deferred task method is not supported by the Github consumer"
      end

      # Returns a hash that defines the following values:  token, message, and results.  For this
      # consumer we raise an error because it does not support completing deferred tasks.
      def complete_deferred_task_handler(bodyContent, httpRequest)
        raise "The complete deferred task method is not supported by the Github consumer"
      end

      # Validate the configuration, returning an non-empty string if there were problems
      # usually used to validate configurable properties
      def validate
      end
    end
  end
end
