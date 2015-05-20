# Prerequisites

- Ruby 2.2.2
- Rails 4.2.1
- Bundler 1.9.6
- Node 0.12.3
- npm 2.9.1
- ember-cli 0.2.5
- [watchman 3.1.0](http://www.ember-cli.com/#watchman)

# Building discoteca

## the Rails back-end

To gain some time, we will use a Ruby on Rails template to generate the API that will serve the data.

Go see the template ```support/template.rb``` it's commented.

And now run:

- `rails new discoteca --skip-sprockets --skip-test-unit --skip-javascript --skip-turbolinks --skip-bundle –no-ri –no-rdoc --skip-jbuilder --skip-git --database sqlite3 -m support/template.rb`
- `mv discoteca rails`
- `cd rails`
- `bundle exec rspec` to run our tests

## the Ember front-end

- `ember new discoteca --skip-git`
- `mv discoteca ember`
- `cd discoteca ember`

Start the server:

`ember server --proxy=http://localhost:3000`

This commande start the server to serve our application and the `--proxy` flag tells the server to proxy all ajax requests to the given address.

and visit [http://localhost:4200](http://localhost:4200).

Ember greats us!

We can also see our ember tests running by visiting [http://localhost:4200/tests](http://localhost:4200/tests).

All tests are green whisch is expected since we stil don't have modified anything.


To exploit our API, we will use the powerfull (and controversial) ember-data.
At this time ember-data is still beta (v1.0.0-beta.17) but v1 is planned to be released early june.

- ORM-like library for ember.js
- uses Promises
- manage loading and saving records.

Ember-Data match to your API through an adapter library. You can change this adapter to match your api, either by creating your own or chosing an existing one.


So ember-cli is a cli for ember:
  - it provides a series of generators: `ember help generate`

So let's generate an adapter for our application:

`ember g adapter application`


By default it uses the DS.RESTAdapter. Since we've built our api with active_model_serializers, we have to tell ember-data to use its built-in [DS.ActiveModelAdapter](http://emberjs.com/api/data/classes/DS.ActiveModelAdapter.html).

The ActiveModelAdapter is a subclass of the RESTAdapter designed to integrate with a JSON API that uses an underscored naming convention instead of camelCasing, as the one provided by active_model_serializers.

We will also tell our adapter to request our API with url namespaced with 'api/vi/' by giving it a 'namespace' option:


```
import DS from 'ember-data';

export default DS.ActiveModelAdapter.extend({
   namespace: 'api/v1/'
});
```

<!---
Reload the page and open the console: -> errors that have to be corrected
-->

Then correct the [content-security-policy](http://www.ember-cli.com/#content-security-policy) by editing `env.js and add:

```
module.exports = function(environment) {
  var ENV =
    contentSecurityPolicy: {
      'default-src': "'none'",
      'script-src': "'self' https://maxcdn.bootstrapcdn.com/",
      'font-src': "'self' https://maxcdn.bootstrapcdn.com/",
      'connect-src': "'self'",
      'img-src': "'self' http://upload.wikimedia.org/",
      'style-src': "'self' 'unsafe-inline' https://maxcdn.bootstrapcdn.com/",
      'media-src': "'self'",
      'report-uri': "http://localhost:4200"
    },
    …
```

And add quickly add bootstrap via CDN for styling the app (in app.html):

```
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
```

Change the title in application.hbs to Discoteca (and add some bootsrtrap markup).

```
<div class='container'>
  <div class='row'>
    <div class='col-sm-12'>
      <h1 id="title">Discoteca</h1>
      {{outlet}}
    </div>
  </div>
</div>
```

It would be nice to see a list of artists when we visit the /artists route

Let's try to TDD that by creating an acceptance test: `ember g acceptance-test artists`

Modify the test:

```
test('visiting /artists', function(assert) {
  visit('/artists');

  andThen(function() {
    assert.equal(currentPath(), 'artists', "correct PATH was transitioned into.");
    assert.equal(find("h2:contains(Artists)").length, 1, "There is a title 'Artists'");
    assert.equal(find(".artist").length, 12, 'We can see 12 artists');
  });
});
```

To make this test pass we have to create the artist resource (model, route):

`ember generate resource artists name:string`

Bunch of things is generated…


Let's change the route/artists to get the model from the API.

```
model: function(){
  return this.store.find('artist');
}
```

and change the artists.hbs template to actually show the artists

````
<div class='row'>
  <div class='col-sm-3'>
    <h2>Artists</h2>
    <ul class='artists list-group'>
      {{#each artist in controller}}
        <li class="list-group-item artist">
          {{artist.name}}
        </li>
      {{/each}}
    </ul>
  </div>
  <div class='col-sm-9'>
    {{outlet}}
  </div>
</div>
`````

The artists are all scrambled.
Let's sort them by name.

We have to create a the artists controller for this.

`ember generate controller artists`

and add the sort properties there.

```
import Ember from 'ember';

export default Ember.ArrayController.extend({
  sortProperties: ['name']
});
```

It would be great to see the details of an artist when clicking its name…

Let' write a test for this…

```
test('visiting /artists', function(assert) {
  visit('/artists');

  andThen(function() {
    assert.equal(currentPath(), 'artists.index');
    assert.equal(find("h2:contains(Artists)").length, 1, "There is a title 'Artists'");
    assert.equal(find(".artist").length, 12, 'We can see 12 artists');

    find(".artists .artist a").click();
  });

  andThen(function() {
    assert.equal(currentPath(), 'artists.show', "correct PATH was transitioned into.");
    assert.equal(find(".artist-details").length, 1, "We can see the details of an artist");
    assert.equal(find(".artist-details h3.artist-name").length, 1, "We see the name of the artist as title");
  });
});
```

To make this pass generate the route:

`ember g route artists/show  --path=:artist_id`

Here we define :artist_id as a dynamic segment

and change route/artists/show to get the following model

```
import Ember from 'ember';

export default Ember.Route.extend({
  model: function(params){
    return this.store.find('artist', params.artist_id);
  }
});
```

and the show template:

```
<div class='row'>
  <div class='col-sm-12 artist-details'>
    <h3 class='artist-name'>{{model.name}}</h3>
  </div>
</div>
```

And link to each artists in templates/artists.hbs:

```
<div class='row'>
  <div class='col-sm-3'>
    <h2>Artists</h2>
    <ul class='artists list-group'>
      {{#each artist in controller}}
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
```

Let's show the associated albums:

```
andThen(function() {
  assert.equal(currentPath(), 'artists.show');
  assert.equal(find(".artist-details").length, 1, "We can see the details of an artist");
  assert.equal(find(".artist-details h3.artist-name").length, 1, "We see the name of the artist as title");
  assert.equal(find(".artist-albums h4:contains(Albums)").length, 1, "We see the albums list title");
  assert.equal(find(".artist-albums").length, 1, "We see the artist album list");
  assert.equal(find(".artist-albums .album").length, 3, "We see 3 different albums");
});
```

The template…

```
<div class='row'>
  <div class='col-sm-12 artist-details'>
    <h3 class='artist-name'>{{model.name}}</h3>
    {{#if model.albums}}
      <div class="artist-albums">
        <h4>Albums ({{model.albums.length}})</h4>
        {{#each album in model.albums}}
          <div class="artist-album row">
            <div class="col-sm-3">
              <img class="img-thumbnail pull-left" src={{album.artworkUrl}} alt="album artwork" width='150'>
            </div>
            <div class="col-sm-9">
              <h5>
                {{album.name}}
                <br>
                <small>
                  Issued {{album.releasedOn}}
                </small>
              </h5>
            </div>
          </div>
        {{/each}}
      </div>
    {{else}}
      <div class='well'>
        No album yet
      </div>
    {{/if}}
  </div>
</div>
```

To make it work we have to create a new Ember-Data model: the Album

`ember g model album name:string released_on:date artwork_url:string artist:belongsTo`

change the album.js model to load the associated artist asynchronously:

`artist: DS.belongsTo('artist', {async: true})`

and tel the artist.js model to load the associated albums too.

`albums: DS.hasMany('album', {async: true})`



Let's add the possibility to create an artist

`ember g route artists/new  --path=:new`

and change route/artists/new to create a new artist

```
import Ember from 'ember';

export default Ember.Route.extend({
  model: function(){
    return this.store.createRecord('artist');
  }
});
```

artists/new template

```
<div class='row'>
  <div class="col-md-12">
    <h3>
      New artist {{model.name}}
    </h3>
  </div>
  <div class="col-md-6">
    <form {{action "save" on="submit"}}>
      <div class="form-group {{if model.errors.name 'has-error has-feedback' 'has-no-error'}}">
        {{input value=model.name classNames='form-control' placeholder='Name'}}
        {{#each error in model.errors.name}}
          <span class="glyphicon glyphicon-remove form-control-feedback" aria-hidden="true"></span>
          <p class="text-danger pull-right">Name {{error.message}}</p>
        {{/each}}
      </div>
      <input type="submit" value="Save" class="btn btn-success">
      <button {{action "cancel"}} class="btn btn-default">cancel</button>
    </form>
  </div>
</div>
```

and to actually save the record, you have to add an action to the controller

```
import VersionsBaseController from './base';

export default VersionsBaseController.extend({
  actions: {
    cancel: function() {
      this.model.rollback();
      this.transitionToRoute('artists');
    },
    save: function() {
      var _this = this;
      this.get('model.artist').save();
      this.get('model').save().then(function(artist) {
        _this.transitionToRoute('artists.show', artist);
      });
    }
  }
});
```

When we try this it fails with an error 422.
It's a CSRF it's due to an ActionController::InvalidAuthenticityToken error.
This can be corrected by adding the CSRF key to the header of the request.
An there's an addon for that.

https://github.com/abuiles/rails-csrf

Let's install it: `npm install rails-csrf --save`
and modify ember/app/app.js by adding

```
import { setCsrfUrl } from 'rails-csrf/config';

setCsrfUrl('http://localhost:3000/api/csrf');

loadInitializers(App, 'rails-csrf');
```

We also have to allow CORS coming from the ember app in the rails app.
Add `gem 'rack-cors', require: 'rack/cors'` a gem that provides support for Cross-Origin Resource Sharing (CORS) for Rack compatible web applications, like rails.

And the allow CORS to localhost:4200 in application.rb:

```
config.action_dispatch.default_headers = {
  'Access-Control-Allow-Origin' => 'http://localhost:4200'
}
```

And now it works.
We can see that if validation fails and the server returns errors, the save() Ember-Date promises fails and automatically adds the errors to the model.

We can now add a link to the new form in artists.hbs:

```
<div class='row'>
  <div class='col-sm-3'>
    <h2>
      Artists
      {{#link-to "artists.new" classNames='btn btn-success btn-small' title="Enter a new artist"}}
        <span class="glyphicon glyphicon-plus"></span>
      {{/link-to}}
    </h2>
    <ul class='list-group'>
      {{#each artist in controller}}
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
```

Let's add the possibility to destroy an artist.

This time we don't need an artist, a simple controllers/artists.js action is enough.

```
import Ember from 'ember';

export default Ember.ArrayController.extend({
  sortProperties: ['name'],
  sortAscending: true,

  actions: {
    delete: function(artist){
      var _this = this;
      if (window.confirm("Are you sure you want to delete this artist?")) {
        debugger;
        artist.destroyRecord().then(function(v) {
          _this.transitionTo('artists');
        });
      }
    }
  }
});
```


And a simple link to the action for every artists in artists.hbs

```
<div class='row'>
  <div class='col-sm-3'>
    <h2>
      Artists
      {{#link-to "artists.new" classNames='btn btn-success btn-small' title="Enter a new artist"}}
        <span class="glyphicon glyphicon-plus"></span>
      {{/link-to}}
    </h2>
    <ul class='list-group'>
      {{#each artist in controller}}
        <li class="list-group-item artist">
          {{link-to artist.name "artists.show" artist}}
          <a href="#" {{action "delete" artist}} class="text-danger pull-right" title="Destroy this version" data-toggle="tooltip" data-placement="top">
            <span class="glyphicon glyphicon-trash"></span>
          </a>
        </li>
      {{/each}}
    </ul>
  </div>
  <div class='col-sm-9'>
    {{outlet}}
  </div>
</div>
```

Let's add the possibility to edit an artist

`ember g route artists/edit  --path=:artist_id/edit`

and change route/artists/edit to get the following model

```
import Ember from 'ember';

export default Ember.Route.extend({
  model: function(params){
    return this.store.find('artist', params.artist_id);
  }
});
```

For the artists/edit.hbs template, let's reuse the form we'have alread built by creating a partial:

```
<div class='row'>
  <div class="col-md-12">
    <h3>
      Edit artist {{model.name}}
    </h3>
  </div>
  <div class="col-md-6">
    {{partial 'artists/form'}}
  </div>
</div>
```

and the artists/-form.hbs partial:

```
<form {{action "save" on="submit"}}>
  <div class="form-group {{if model.errors.name 'has-error has-feedback' 'has-no-error'}}">
    {{input value=model.name classNames='form-control' placeholder='Name'}}
    {{#each error in model.errors.name}}
      <span class="glyphicon glyphicon-remove form-control-feedback" aria-hidden="true"></span>
      <p class="text-danger pull-right">Name {{error.message}}</p>
    {{/each}}
  </div>
  <input type="submit" value="Save" class="btn btn-success">
  <button {{action "cancel"}} class="btn btn-default">cancel</button>
</form>
```

We can use the same partial in artist/new.hbs:

```
<div class='row'>
  <div class="col-md-12">
    <h3>
      New artist {{model.name}}
    </h3>
  </div>
  <div class="col-md-6">
    {{partial "artists/form"}}
  </div>
</div>
```

We have to implement the save and cancel actions in the artists/edit.js controller:

```
import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    cancel: function() {
      this.model.rollback();
      this.transitionToRoute('artists.show', this.model);
    },
    save: function() {
      var _this = this;
      this.get('model').save().then(
        function(artist) {
          _this.transitionToRoute('artists.show', artist);
        },
        function(){}
      );
    }
  }
});
```

Since the save action is identical in the new.js and edit.js controllers, we can extract it in a common base controller:

```
import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    save: function() {
      var _this = this;
      this.get('model').save().then(
        function(artist) {
          _this.transitionToRoute('artists.show', artist);
        },
        function(){}
      );
    }
  }
});
```

and change new.js to:

```
import ArtistsBaseController from './base';

export default ArtistsBaseController.extend({
  actions: {
    cancel: function() {
      this.model.rollback();
      this.transitionToRoute('artists');
    }
  }
});
```

and edit.js to:

```
import ArtistsBaseController from './base';

export default ArtistsBaseController.extend({
  actions: {
    cancel: function() {
      this.model.rollback();
      this.transitionToRoute('artists.show', this.model);
    }
  }
});
```

Let's add the edit link in artists.hbs:

```

```

Style the active link!
Ember adds an .active class to link with current url.

Let's add

```
.list-group a.active {
  font-weight: bold;
  color: red;
}
```

to app.css

Format the releasedOn date of album with moment.js.

`bower install moment -save`

`ember g component format-date`

Edit components/format-date.js

```
import Ember from 'ember';

export default Ember.Component.extend({
  formattedDate: function(){
    return window.moment(this.get('date')).format(this.get('format'));
  }.property('date')
});
```
and format-date.hbs

`<small>{{prependText}} {{formattedDate}}</small>
`

and now change artists/show.hbs

```
<div class='row'>
  <div class='col-sm-12 artist-details'>
    <h3 class='artist-name'>{{model.name}}</h3>
    {{#if model.albums}}
      <div class="artist-albums">
        <h4>Albums ({{model.albums.length}})</h4>
        {{#each album in model.albums}}
          <div class="artist-album row">
            <div class="col-sm-3">
              <img class="img-thumbnail pull-left" src={{album.artworkUrl}} alt="album artwork" width='150'>
            </div>
            <div class="col-sm-9">
              <h5>
                {{album.name}}
                <br>
                {{formatted-date date=album.releasedOn format='LL' prependText='Issued'}}
              </h5>
            </div>
          </div>
        {{/each}}
      </div>
    {{else}}
      <div class='well'>
        No album yet
      </div>
    {{/if}}
  </div>
</div>
```

Done for today!

