data_seeder Changelog
=====================

1.0.6 / 2016-03-02
  - Allow config open_options to allow setting options on File.open (i.e., open_options: {encoding: 'ISO-8859-1:UTF-8'})

1.0.5 / 2016-02-19
  - Fix bug in test_run (Yes, I'm a dumbass)

1.0.4 / 2016-02-19
  - Fix bug in quiet_run

1.0.3 / 2016-02-19
  - Log messages are now info instead of debug.
  - DataSeeder.test_run deprecated in favor of quiet_run which logs to Rails.log instead of $stdout
  - Config continue_on_exception added for txt,csv.
  - No longer use $INPUT_LINE_NUMBER to count line numbers as JRuby has issues.

1.0.2 / 2016-02-17
  - Bug fix the default_config stuff.

1.0.1 / 2016-02-17
  - Deprecate class method default_config and prefer instance method instead
    so it can be used in manual seeding.

1.0.0 / 2016-02-15

  - Allow multiple seed directories.
  - Allow dependencies.
  - Get rid of some superfluous features (see incompatibilities in README)
  - Use separate instance of Loader for each seed file to clean things up and allow for
    possible multithreading support.

0.0.5 / 2015-10-27

  - Partial work around for JRuby 9030 bug where $INPUT_LINE_NUMBER isn't updated correctly
    (https://github.com/jruby/jruby/issues/3429).  This fixes csv files that have the option
    use_line_number_as_id set true.  txt and other types that use this setting may still fail.
  - If classify fails because of some random file in the data_seeder directory, at least have
    it display a better error message than undefined method 'all' for NilClass.

0.0.4 / 2015-05-06

  - Add postprocess option for manipulating attributes before save

0.0.3 / 2015-03-26

  - require 'English' instead of 'english' to make travis (and maybe users experiencing problems) happy.

0.0.2 / 2015-03-25

  - Mutex DataSeeder#run

  - Added option use_line_number_as_id

  - Allow config to be setup in .cfg file since .csv doesn't work with config as first line.


0.0.1 / 2015-03-15

  - Initial release
