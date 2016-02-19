data_seeder [![Build Status](https://secure.travis-ci.org/bpardee/data_seeder.png?branch=master)](http://travis-ci.org/bpardee/data_seeder)
====================

* http://github.com/bpardee/data_seeder

## Introduction

This gem provides a simple methodology for seeding your database.  Seed files in your
seeds directory are loaded in the database and the checksum is stored away so that the
file will only be re-applied when it is changed.  Each row instance within a file is
converted to an attribute hash and the updates are applied idempotently such that unchanged
rows aren't touched, only those rows that have changes as well as insertions and deletions
are performed.  The extension of the seed file determines how it is loaded.  Extensions that
are supported by default are json, yaml, csv, and txt but homegrown loaders can be defined
as necessary.

## Usage

Add this line to your application's Gemfile and run bundler:

    gem 'data_seeder'

Execute the following and migrate your database:

    rake data_seeder:install:migrations

Add the following to your db/seeds.rb file

    DataSeeder.run

Or if you prefer log messages go to the Rails logger instead of $stdout

    DataSeeder.quiet_run

Add seed files to the db/seed directory as necessary. For instance, suppose you have
the following table:

    create_table :countries do |t|
      t.column :code, 'CHAR(2)', null: false
      t.string :name, null: false
    end

And you have a corresponding db/seed/countries.txt file as follows:

    AD Andorra
    AE United Arab Emirates
    AF Arghanistan

And a db/seed/countries.cfg file as follows:

    {
      key_attribute: 'code',
      line: ->(line) {
        {
          code: line[0,2],
          name: line[3...-1]
        }
      }
    }

The cfg file defines the config attributes associated with the file.  This contents of this file
should eval to a hash.  For this seed file,
the key_attribute says that it will use the 'code' attribute to lookup existing records (defaults to 'id')
and the line function
defines how the line is converted to an attribute hash defining the instance.  


Running rake db:seed will result in the following output:

    # rake db:seed
    Loading countries
      Saving #<Country id: 1, code: "AD", name: "Andorra">
      Saving #<Country id: 2, code: "AE", name: "United Arab Emirates">
      Saving #<Country id: 3, code: "AF", name: "Arghanistan">
      ...
    DataSeeder.run took 560 msec

Repeating the command will not attempt to reload the countries file since it is unchanged:

    # rake db:seed
    DataSeeder.run took 21 msec

Then you notice that you have a typo in Arghanistan so you fix it and repeat the command:

    # rake db:seed
    Loading countries
      Updating AF: {"name"=>["Arghanistan", "Afghanistan"]}
    DataSeeder.run took 231 msec

You will probably want your test environment seeded also.  Adding the following to test/test_helper.rb
will seed your database prior to running tests but will redirect the output to the Rails.logger instead
of stdout.

    DataSeeder.quiet_run

## Loaders

data_seeder has default loaders for txt, csv, json and yml extensions but you can also create
your own custom loaders.
For instance, suppose you had the following tables:

```ruby
create_table "apps" do |t|
  t.string "name"
end

create_table "app_errors" do |t|
  t.integer "app_id"
  t.string  "code"
  t.string  "message"
end
add_index "app_errors", ["app_id"], name: "index_app_errors_on_app_id"
```

And you wanted to load up separate error messages for each app such as the following 2 files:

    # foo.err
    1 Something went wrong
    2 We are seriously foobared
    3 We are less seriously foobared

    # bar.err
    A1 Error message for A1
    A2 Error message for A2
    B1 Error message for B1


Look [here](test/dummy/app/models/app_error_data_seeder.rb) for an example of creating your own custom loader.

To add this seeder, you would create the following config/initializers/data_seeder.rb:

```ruby
MyApp::Application.config.after_initialize do
  DataSeeder.configure do |config|
    config.add_loader('err', AppErrorDataSeeder)
  end
end
```

Executing DataSeeder.run would result in the following:

    Loading errors for new App: bar
      Creating A1: Error message for A1
      Creating A2: Error message for A2
      Creating B1: Error message for B1
    Loading errors for new App: foo
      Creating 1: Something went wrong
      Creating 2: We are seriously foobared
      Creating 3: We are less seriously foobared

## Configurable values

#### continue_on_exception (txt,csv)

Continue processing lines if an exception occurs.

#### depends

Value or array that this model depends on such that they must be seeded first.  Examples:

    {
      depends: ['countries','states']
    }

#### key_attribute

The attribute used to define uniqueness within the model.  Can be a single attribute or an array. Defaults to 'id'

#### klass

Defines the ActiveRecord Class if it can't be inferred from the seed file.

#### line (txt)

Proc used for converting a line to attributes.

#### postprocess

Modify the attributes from the seed file before applying them to the model.

Example:

    {
      key_attribute: 'code',
      postprocess: ->(attrs) {
        {
          code: attrs['country_code'],
          name: attrs['country']
        }
      }
    }

#### purge

Destroys rows that no longer exist in the seed file.

#### update_display_method

Model method used for displaying updates to a model.

#### use_line_number_as_id

Use the line number of the seed file as the id.  Note that csv does not count the header
in the line_number count.

## Incompatibilities from 0.0.x version

Custom seeders should now be specified as a Class and not an instance (MySeeder instead of MySeeder.new)

data_seeder_<config-item> methods within the models are no longer supported.

Using the first line of txt, json, and yaml files as the config is no longer supported.  Move them to
a separate .cfg file.


TODO
----

Add 'sql' loader (with disclaimer that it will temporarily truncate the table)

Caching of long-running stuff via pg_dump, mysqldump, or other?  

Document options (key_attribute, line, postprocess, etc)

Meta
----

* Code: `git clone git://github.com/bpardee/data_seeder.git`
* Home: <https://github.com/bpardee/data_seeder>
* Issues: <http://github.com/bpardee/data_seeder/issues>
* Gems: <http://rubygems.org/gems/data_seeder>

This project uses [Semantic Versioning](http://semver.org/).

Author
------

[Brad Pardee](https://github.com/bpardee)

License
-------

Copyright 2015-2016 Brad Pardee

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
