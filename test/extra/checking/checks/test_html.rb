class Nanoc::Extra::Checking::Checks::HTMLTest < Nanoc::TestCase
  def test_run_ok
    VCR.use_cassette('html_run_ok') do
      with_site do |site|
        # Create files
        FileUtils.mkdir_p('output')
        File.open('output/blah.html', 'w') { |io| io.write('<!DOCTYPE html><html><head><meta charset="utf-8"><title>Hello</title></head><body><h1>Hi!</h1></body>') }
        File.open('output/style.css', 'w') { |io| io.write('h1 { coxlor: rxed; }') }

        # Run check
        check = Nanoc::Extra::Checking::Checks::HTML.create(site)
        check.run

        # Check
        assert check.issues.empty?
      end
    end
  end

  def test_run_error
    VCR.use_cassette('html_run_error') do
      with_site do |site|
        # Create files
        FileUtils.mkdir_p('output')
        File.open('output/blah.html', 'w') { |io| io.write('<h2>Hi!</h1>') }
        File.open('output/style.css', 'w') { |io| io.write('h1 { coxlor: rxed; }') }

        # Run check
        check = Nanoc::Extra::Checking::Checks::HTML.create(site)
        check.run

        # Check
        refute check.issues.empty?
        assert_equal 2, check.issues.size
        assert_equal 'line 1: no document type declaration; will parse without validation: <h2>Hi!</h1>', check.issues.to_a[0].description
        assert_equal 'line 1: end tag for element "H1" which is not open: <h2>Hi!</h1>', check.issues.to_a[1].description
      end
    end
  end
end
