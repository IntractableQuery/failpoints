Object.class_eval do

  def mark_failpoint(*args)
    mark_failpoint_with(caller_locations[0], *args)
  end

  def mark_failpoint_with(caller_info, *args)
    caller_info = [caller_info.path, caller_info.lineno] if !(caller_info.is_a? Array)
    Failpoints.record_failpoint(caller_info)
  end

end
