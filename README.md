# Prerequisites

- Ruby 2.2.2
- Rails 4.2.1
- Bundler 1.9.6
- Node 0.12.2
- npm 2.7.4

# Building discoteca

## the Rails Backend

To gain some time, we will use a Rubo on Rails template to generate the API that will serve the data.

Let's examine the template: support/template.rb.

And now run:

- `rails new discoteca --skip-sprockets --skip-test-unit --skip-javascript --skip-turbolinks --skip-bundle –no-ri –no-rdoc --skip-jbuilder --database sqlite3 -m support/template.rb`
- `mv discoteca rails`
- `cd rails`

Run guard: `bundle exec guard` and our tests…

A few errors that needs to be corrected.

First, add factory_girl and shoulda_matchers to spec/rails_helper.rb

`require 'shoulda/matchers'`
and
`config.include FactoryGirl::Syntax::Methods`

## the front

- `npm install -g ember-cli`
- `mkdir discoteca`
- `cd discoteca`
- `ember new discoteca --skip-git`
- `mv discoteca ember`
