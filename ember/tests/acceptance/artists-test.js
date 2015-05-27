import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'discoteca/tests/helpers/start-app';

var application;

module('Acceptance | artists', {
  beforeEach: function() {
    application = startApp();
  },

  afterEach: function() {
    Ember.run(application, 'destroy');
  }
});

test('visiting /artists', function(assert) {
  visit('/artists');

  andThen(function() {
    assert.equal(currentRouteName(), 'artists.index', "correct PATH was transitioned into.");
    assert.equal(find("h2:contains(Artists)").length, 1, "There is a title 'Artists'");
    assert.equal(find(".artist").length, 12, 'We can see 12 artists');

    find(".artists .artist a[title='Nirvana']").click();
  });

  andThen(function() {
    assert.equal(currentRouteName(), 'artists.show', "correct PATH was transitioned into.");
    assert.equal(find(".artist-details").length, 1, "We can see the details of an artist");
    assert.equal(find(".artist-details h3.artist-name:contains(Nirvana)").length, 1, "We see the name of the artist as title");
    assert.equal(find(".artist-albums h4:contains(Albums)").length, 1, "We see the albums list title");
    assert.equal(find(".artist-albums").length, 1, "We see the artist album list");
    assert.equal(find(".artist-albums .artist-album").length, 3, "We see 3 different albums");
  });
});
