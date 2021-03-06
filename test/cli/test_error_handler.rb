class Nanoc::CLI::ErrorHandlerTest < Nanoc::TestCase
  def setup
    super
    @handler = Nanoc::CLI::ErrorHandler.new
  end

  def test_resolution_for_with_unknown_gem
    error = LoadError.new('no such file to load -- afjlrestjlsgrshter')
    assert_nil @handler.send(:resolution_for, error)
  end

  def test_resolution_for_with_known_gem_without_bundler
    def @handler.using_bundler?
      false
    end
    error = LoadError.new('no such file to load -- kramdown')
    assert_match(/^Install the 'kramdown' gem using `gem install kramdown`./, @handler.send(:resolution_for, error))
  end

  def test_resolution_for_with_known_gem_with_bundler
    def @handler.using_bundler?
      true
    end
    error = LoadError.new('no such file to load -- kramdown')
    assert_match(/^Make sure the gem is added to Gemfile/, @handler.send(:resolution_for, error))
  end

  def test_resolution_for_with_not_load_error
    error = RuntimeError.new('nuclear meltdown detected')
    assert_nil @handler.send(:resolution_for, error)
  end

  def test_write_stack_trace_verbose
    error = new_error(20)

    stream = StringIO.new
    @handler.send(:write_stack_trace, stream, error, verbose: false)
    assert_match(/See full crash log for details./, stream.string)

    stream = StringIO.new
    @handler.send(:write_stack_trace, stream, error, verbose: false)
    assert_match(/See full crash log for details./, stream.string)

    stream = StringIO.new
    @handler.send(:write_stack_trace, stream, error, verbose: true)
    refute_match(/See full crash log for details./, stream.string)
  end

  def new_error(amount_factor)
    backtrace_generator = lambda do |af|
      if af == 0
        raise 'finally!'
      else
        backtrace_generator.call(af - 1)
      end
    end

    begin
      backtrace_generator.call(amount_factor)
    rescue => e
      return e
    end
  end
end
