data_seeder
====================

* http://github.com/bpardee/data_seeder

## Introduction

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

    # config: { key_attr: 'code', line: ->(line) { { code: line[0,2], name: line[3...-1] } } }
    AD Andorra
    AE United Arab Emirates
    AF Arghanistan

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
