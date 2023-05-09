require "active_record"

$is_running_tests = true
require_relative "test_helper.rb"

# Grab all that inherit from ActiveSupport::TestCase
all_test_classes = ObjectSpace.each_object(Class).select { |klass| klass < ActiveSupport::TestCase }

puts "[Debug] all_test_classes = " + all_test_classes.to_s

# Run all the tests
all_test_classes.each do |test_class|
  puts "~~~ Running tests for " + test_class.to_s + " ~~~"
  # test_class is a child of ActiveSupport::TestCase, 1 argument
  test_class_obj = test_class.new("test")
  test_class.public_instance_methods(false).each do |test_method|
    if test_method.start_with?("test_")
      puts "Running " + test_method.to_s
      test_class_obj.send(test_method.to_sym)
    end
  end
end

puts "~~~ All tests passed ~~~"
