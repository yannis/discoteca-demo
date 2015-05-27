import Ember from 'ember';

export default Ember.ArrayController.extend({
  sortProperties: ['name'],

  actions: {
    delete: function(artist){
      var _this = this;
      if (window.confirm("Are you sure you want to delete this artist?")) {
        artist.destroyRecord().then(function() {
          _this.transitionTo('artists');
        });
      }
    }
  }
});
