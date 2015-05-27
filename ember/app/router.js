import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('artists', function() {
    this.route('show', {
      path: ':artist_id'
    });
    this.route('new', {
      path: 'new'
    });

    this.route('edit', {
      path: ':artist_id/edit'
    });
  });
});

export default Router;
