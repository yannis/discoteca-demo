# Prerequisites

- Ruby 2.2.2
- Rails 4.2.1
- Bundler 1.9.6
- Node 0.12.3
- npm 2.9.1
- ember-cli 0.2.4
- [watchman 3.1.0](http://www.ember-cli.com/#watchman)

# Building discoteca

## the Rails back-end

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

## the Ember front-end

- `ember new discoteca --skip-git`
- `mv discoteca ember`
- `cd discoteca ember`

Start the server:

`ember server --proxy=http://localhost:3000`

This commande start the server to serve our application and the `--proxy` flagtells the server to proxy all ajax requests to the given address.

To exploit our API, we will use the powerfull (and controversial) ember-data.
At this time ember-data is still beta (v1.0.0-beta.17) but v1 is planned to be released early june.
It's an ORM-like library for ember.js that uses Promises/A+-compatible promises from the ground up to manage loading and saving records.

Ember-Data match to your API through an adapter library. You can change this adapter to match your api, either by creating your own or chosing an existing one.

So let's generate an adapter for our application:

`ember g adapter application`


By default it uses the DS.RESTAdapter. Since we've built our api with active_model_serializers, we have to tell ember-data to use its built-in DS.ActiveModelAdapter.

We will also tell our adapter to request our API with url namespaced with 'api/vi/' by giving it a 'namespace' option:

`
import DS from 'ember-data';

export default DS.ActiveModelAdapter.extend({
   namespace: 'api/v1/'
});
`


Then correct the [CSP](http://www.ember-cli.com/#content-security-policy) by editing env.js and add:

`
module.exports = function(environment) {
  var ENV = {
    contentSecurityPolicy: {
      'default-src': "'none'",
      'script-src': "'self' https://maxcdn.bootstrapcdn.com/",
      'font-src': "'self' https://maxcdn.bootstrapcdn.com/",
      'connect-src': "'self'",
      'img-src': "'self'",
      'style-src': "'self' 'unsafe-inline' https://maxcdn.bootstrapcdn.com/",
      'media-src': "'self'"
    },
    …
`

And add quickly add bootstrap via CDN for styling the app (in app.html):

`
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
<script src="https:///bootstrap/3.3.4/js/bootstrap.min.js"></script>


So ember-cli is a cli for ember:
  - it provides a series of generators: `ember help generate`

Let's create our first resource:

`ember generate resource artists name:string`

Bunch of things is generated…

What we would like to do for know is being able to see a list of artists when we visit /artists…

Let's try to TDD that…

`ember g acceptance-test artists`

Modify the test:

`
test('visiting /artists', function(assert) {
  visit('/artists');

  andThen(function() {
    assert.equal(currentPath(), 'artists');
    assert.equal(find("h2:contains(Artists)").length, 1);
    assert.equal(find(".artist").length, 10);
  });
});
`
To make this pass

change route/artists to get the following model
`
model: function(){
  return this.store.find('artist');
}
`

and change the artists.hbs template to actually show the artists

`
<div class='row'>
  <div class='col-sm-3'>
    <h2>Artists</h2>
    <ul class='list-group'>
      {{#each artist in model}}
        <li class="list-group-item artist">
          {{link-to artist.name "artists.show" artist}}
        </li>
      {{/each}}
    </ul>
  </div>
  <div class='col-sm-9'>
    {{outlet}}
  </div>
</div>
`

It would be great to see the details of an artist when clicking its name…

Let' write a test for this…

test('visiting /artists', function(assert) {
  visit('/artists');

  andThen(function() {
    assert.equal(currentPath(), 'artists');
    assert.equal(find("h2:contains(Artists)").length, 1);
    assert.equal(find(".artist").length, 10);

    find(".artists .artist:first-of-type a").click();
  });

  andThen(function() {
    assert.equal(currentPath(), 'artists.show');
    assert.equal(find(".artist-details").length, 1);
    assert.equal(find(".artist-details h3.artist-name").length, 1);
  });
});
`
To make this pass genarte the route:

`ember g route artists/show  --path=:artist_id`

and change route/artists/show to get the following model

`
import Ember from 'ember';

export default Ember.Route.extend({
  model: function(params){
    var artists = this.modelFor('artists');
    return artists.findBy('id', params.id);
  }
});
`

and the show template:

`
<div class='row'>
  <div class='col-sm-12 artist-details'>
    <h3 class='artist-name'>{{model.name}}</h3>
  </div>
</div>
`

Let's show the associated albums:

`

  click('.artist a').then(function() {
    assert.equal(currentPath(), 'artists.show');
    assert.equal(find(".artist-details").length, 1);
    assert.equal(find(".artist-details h3.artist-name").length, 1);
    assert.equal(find(".artist-albums h4:contains(Albums)").length, 1);
    assert.equal(find(".artist-albums").length, 1);
    assert.equal(find(".artist-albums .album").length, 3);
  });
`

The template…

`
<div class='row'>
  <div class='col-sm-12 artist-details'>
    <h3 class='artist-name'>{{model.name}}</h3>
    {{#if model.albums}}
      <div class="artist-albums">
        <h4>Albums</h4>
        <ul class="list-group">
          {{#each album in model.albums}}
            <li class="list-group-item">
              {{album.name}}
              ({{album.issued_on}})
            </li>
          {{/each}}
        </ul>
      </div>
    {{/if}}
  </div>
</div>
`

To make it work we have to create a new Ember-Data model: the Album

`ember g model album name:string issued_on:date artwork_url:string artist:belongsTo`

- speak about ES6 modules structure
- tests
- ember data state
- ember chrome/firefox extension

