import Ember from 'ember';
import Resolver from 'ember/resolver';
import loadInitializers from 'ember/load-initializers';
import config from './config/environment';
import { setCsrfUrl } from 'rails-csrf/config';

var App;

Ember.MODEL_FACTORY_INJECTIONS = true;

App = Ember.Application.extend({
  modulePrefix: config.modulePrefix,
  Resolver: Resolver
});

setCsrfUrl('/api/csrf');

loadInitializers(App, 'rails-csrf');

loadInitializers(App, config.modulePrefix);

export default App;
