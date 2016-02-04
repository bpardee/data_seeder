data_seeder Changelog
=====================

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
