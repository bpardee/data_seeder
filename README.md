data_seeder
====================

* http://github.com/bpardee/data_seeder

## Introduction

TODO: Still under initial development, not quite ready for prime-time.

This gem providies a simple methodology for seeding your database.  Seed files in your
seeds directory are loaded in the database and the checksum is stored away so that the
file will only be re-applied when it is changed.  Each row instance within a file is
converted to an attibute hash and the updates are applied idempotently such that unchanged
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

Add seed files to the db/seed directory as necessary. For instance, suppose you have
the following table:

    create_table :countries do |t|
      t.column :code, 'CHAR(2)', null: false
      t.string :name, null: false
    end

And you have a corresponding db/seed/countries.txt file as follows:

    # config: { key_attribute: 'code', line: ->(line) { { code: line[0,2], name: line[3...-1] } } }
    AD Andorra
    AE United Arab Emirates
    AF Arghanistan

The first line in a file can define the config attributes associated with the file.  For this seed file,
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

    DataSeeder.test_run

TODO
----

Caching of long-running stuff via pg_dump, mysqldump, or other?

Ability to specify more than 1 directory for Rails.env overrides.  Could potentially be used if you have that
x Gigabyte seed file that you don't want to check into source control and only want run on production?

Ability to stop early when loading up a large seed file for a given environment, i.e., stop after processing the
first 10 lines when Rails.env.test?

YAML should allow loading as either array or hash. (currently only does hash)

CSV isn't implemented and should have options such as only: and except: for using/skipping the specified header columns.

Allow multi-line config statement in seed file header?  Would somehow need to mark it as such via end-of-line mark or
beginning-of-line mark or maybe use '#-' or '#%' for all command-type lines?

The structure.sql caching within rails uses the file timestamp to determine whether to do a db:test:prepare.  This
is error prone and forces you to do a 'touch db/structure.sql' to get around the not getting reloaded problem.  Should
I add a utility to override this rails implementation with a sha-based one like the seed files use?

Add 'sql' loader (with disclaimer that it will temporarily truncate the table)

I want to allow different seeding for different environments.  For instance development might have a bunch of dummy
data useful for getting an environment up and running.  I'm thinking either the seed_dir similar to like a PATH
environment variable where the first one found would override the others, or maybe make it automatic based on the
directory names and the environment (seed.development/state.yml would override seed/state.yml).

The test environment will be the one that will constantly being seeded after migrations or branch changes.  Some of
the seed files might be large and take a long time to seed.  The above
strategy using seed.test might be useful but it might also be useful to have a preprocessor type such as .sh so for
instance you might have seed.test/table_with_lotsa_rows.csv.sh which might consist of the line
'head -20 ../seed/table_with_lotsa_rows.csv'

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

Copyright 2015 Brad Pardee

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
