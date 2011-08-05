module Sock
  def self.create(described, &description)
    describe described do
      yield SockDrawer.new(described)
    end
  end

  def self.find(described, description)
    SockDrawer.find(described, description)
  end

  class Sock
    def initialize(object)
      @described = object
      @events = []
      @mode = :mock
    end

    def stub
      stubber = self.clone # new instance shares the same event list
      stubber.instance_eval do
        @mode = :stub
      end
      stubber
    end

    def method_missing(name, *args)
      @described.send(name, *args).tap do |result| 
        @events << [@mode, {:method => name, :args => args, :result => result}]
      end
    end

    def run_events
      @events.each do |record_type, record_details|
        mock_method = record_type.to_sym == :mock ? :should_receive : :stub
        @described.send(mock_method, record_details[:method]).with(*record_details[:args]).and_return(record_details[:result])
      end
      @described
    end
  end

  class SockDrawer
    def self.drawer
      @drawer ||= {}
    end

    def self.find(described, description)
      drawer[[described, description]].run_events
    end

    def drawer
      self.class.drawer
    end

    def initialize(described)
      @described = described
    end
  
    def case(description, subject, &case_block)
      sock = Sock.new(subject)
      drawer[[@described, description]] = sock
      describe description do
        yield sock
      end
    end

  end
end
