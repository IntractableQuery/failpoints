# Failpoints

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'failpoints'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install failpoints

## Usage

This library is for testing algorithms which are meant to be recoverable.  You can "record" a run of the algorithm to
determine places it can fail (generally, a line in a source file), and then later, you can force a failure at those
places.

It was specifically designed for a use-case where a one-way sync algorithm that runs bulk jobs on the Salesforce API
needed to be tested to ensure that it provided eventual data consistency despite failure at critical points of the
process (which for our purposes, is any point where we made a bulk data load in the API, deleted data, or otherwise
interacted with the API to alter the state of the remote Salesforce sandbox).

It adds methods to Object:

    # Indicates the file and line number of this method invokation is a failure point
     mark_failpoint

    # Like #mark_failpoint, but you can specify the point of failure manually -- useful if you have some piece of code
    # that is invoked several times by the algorithm, and you'd like to offer an opportunity to fail unique to the
    # caller
    mark_failpoint_with(some_handler_lambda.source_location)

It is critical to note that mark_failpoint_with specifying the "location" does not cause a literal failure
at the location specified, but the opportunity to fail at the next invokation of #mark_failpoint_with when the
location is matched.  In this sense, location means nothing and is really just a unique specifier of some point
in the algorithm that can fail.

Now, you can record the run of your algorithm via a "trace".  See the source for available methods to do this, but
here's one way:

    # Record a trace
    trace = Failpoints.trace do
      MyAlgorithm.new.do_things # Contains calls to mark_failpoint as necessary
    end

This results in a set of filenames and lines of code that are good places for your algorithm to fail, assuming you
setup your failpoints reasonably.  If you're writing a test suite, your first test should run a complete successful
instance of the algorithm, recording the trace for later (perhaps to a temp file).

Next, we can use #fail_by_trace to force a failure somewhere:

    # Force a failure
    Failpoints.fail_by_trace(trace, 1) do # Force failure at index 1 of trace
      MyAlgorithm.new.do_things
    end

In your test suite, you could increment the failure index to get complete coverage of all failpoints.  If you want an
opinionated way to reduce the number of places to test, try Failpoints.minimum_test_indexes(trace).  This looks
for repeated failpoint source/line definitions that occur in sequence and returns indexes of only the first and last.
This tends to provide "good coverage" for algorithms that may do the same thing over and over (maybe even thousands
of times!).

## TODO

* Really need tests, especially since this is supposed to support the tests of others :)
* Need more real-world examples

## Contributing

1. Fork it ( https://github.com/[my-github-username]/failpoints/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
