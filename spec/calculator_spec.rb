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
  Sock.create(Calculator) do |so|
    so.case(:multiplying_to_6, Calculator.new) do |sock|
      before do
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
    @pricer = Pricer.new(@calculator)
    @pricer.price.should == 6
  end
end
