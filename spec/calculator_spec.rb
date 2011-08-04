require 'spec_helper'

class Calculator
  def initialize
    @stack = []
  end

  def push(n)
    @stack << n
  end

  def mul
    pop * pop
  end

  def pop
    @stack.pop
  end
end

class Pricer
  def initialize(calculator)
    @calculator = calculator
  end

  def quantity_required(n)
    @calculator.push(n)
  end

  def cost_per_unit(price)
    @calculator.push(price)
  end

  def price
    @calculator.mul
  end
end

describe Calculator do
  # we're writing a spec that also defines a mock. The mock can be retrieved 
  # with [Calculator, :multiplying_to_6], and it starts off as a Calculator.new
  Sock.create(Calculator) do |so|
    so.case(:multiplying_to_6, Calculator.new) do |sock|
      # sock acts like a Calculator.new that also records methods called on it.
      # By default, the eventual mock will expect recorded methods to be called
      before do
        # sock.stub means that the method will be stubbed in without an
        # expectation
        sock.stub.push 2
        sock.stub.push 3
      end
  
      it "should return 6" do
        sock.mul.should == 6
      end
    end
  end
end

describe Pricer do
  it "should use the mock" do
    @calculator = Sock.find(Calculator, :multiplying_to_6)
    # we install the mock captured by the [Calculator, :multiplying_to_6] sock
    # so this line is equivalent to
    #   @calculator = Calculator.new
    #   @calculator.stub(:push).with(2)
    #   @calculator.stub(:push).with(3)
    #   @calculator.should_receive(:mul).and_return(6)
    # and the test will fail if Pricer produces the answer without using the
    # @calculator
    @pricer = Pricer.new(@calculator)
    @pricer.price.should == 6
  end
end
