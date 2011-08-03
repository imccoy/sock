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
    end

    def stub
      SockStubber.new(self)
    end

    def record_and_do(record_type, method_name, args)
      @events << [record_type, {:method => method_name, :args => args}]
      @described.send(method_name, *args)
    end

    def method_missing(name, *args)
      SockAsserter.new(self, name, args)
    end

    def add_result(result)
      @events.last[1][:result] = result
    end

    def run_events
      @events.each do |record_type, record_details|
        mock_method = record_type.to_sym == :mock ? :should_receive : :stub
        mock = @described.send(mock_method, record_details[:method]).with(*record_details[:args])
        if record_details.include?(:result)
          mock.and_return(record_details[:result])
        end
      end
      @described
    end
  end

  class SockStubber
    def initialize(sock)
      @sock = sock
    end

    def method_missing(name, *args)
      @sock.record_and_do(:stub, name, *args)
    end
  end

  class SockAsserter
    def initialize(sock, name, args)
      @sock = sock
      @name = name
      @args = args
    end

    def should
      self
    end

    def ==(matcher)
      result = @sock.record_and_do(:mock, @name, @args)
      @sock.add_result(result)
      result.should == matcher
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
