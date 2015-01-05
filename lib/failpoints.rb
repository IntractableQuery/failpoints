require "failpoints/version"

module Failpoints

  class FailpointAbortException < Exception; end
  class FailpointMismatchException < Exception; end

  def self.trace
    @@recorded_failpoints = []

    begin
      yield
    ensure
      recorded = @@recorded_failpoints
      @@recorded_failpoints = nil
    end

    recorded
  end

  def self.trace_to_file(filename, &block)
    failpoints = self.trace(&block)
    self.save_trace(filename, failpoints)
    failpoints
  end

  def self.save_trace(filename, failpoints)
    File.open(filename, 'w') { |f| f.write failpoints.to_yaml }
  end

  def self.load_trace(filename)
    YAML::load_file(filename)
  end

  ##
  # Determines the simplest set of indexes in the trace we can fail at and still get good
  # coverage.  This essentially removes indexes pointing to repeated operations, instead
  # opting only to index the first and last of a sequence of the exact same operations.
  def self.minimum_test_indexes(trace)
    nilled_trace_items = trace.each_with_index.map do |line, index|
      left = (index-1 >= 0) ? trace[index-1] : nil
      right = (index+1 < trace.size) ? trace[index+1] : nil
      if left == line && right == line
        nil
      else
        line
      end
    end

    nilled_trace_items.each_with_index.map do |line, index|
      if line.nil?
        nil
      else
        index
      end
    end.compact
  end

  def self.fail_by_trace(trace, index)
    @@original_trace_to_fail_by = trace
    @@trace_to_fail_by = trace.dup
    @@index_to_fail_at = index
    @@current_fail_index = 0
    begin
      yield
    ensure
      @@original_trace_to_fail_by = nil
      @@trace_to_fail_by = nil
      @@index_to_fail_at = nil
      @@current_fail_index = nil
    end
  end

  def self.record_failpoint(location)
    location = location.to_s # normalize

    if defined?(@@recorded_failpoints) && (@@recorded_failpoints != nil)
      @@recorded_failpoints << location
    end

    if defined?(@@trace_to_fail_by) && (@@trace_to_fail_by != nil)
      # Match current location vs trace to fail by, to be sure we're on the right path
      expected_location = @@trace_to_fail_by.shift
      if expected_location != location
        raise FailpointMismatchException, "failpoint #{location} diverges from trace to fail by at index #{@@current_fail_index}:\n#{@@original_trace_to_fail_by}"
      end

      if @@current_fail_index == @@index_to_fail_at
        raise FailpointAbortException
      end

      @@current_fail_index += 1
    end
  end

end