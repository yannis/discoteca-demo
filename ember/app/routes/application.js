import Ember from 'ember';

export default Ember.Route.extend({
  beforeModel: function() {
    return this.csrf.fetchToken();
  },
  // redirect: function(){
  //   this.transitionTo('artists');
  // }
});
