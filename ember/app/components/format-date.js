import Ember from 'ember';

export default Ember.Component.extend({
  formattedDate: function(){
    return window.moment(this.get('date')).format(this.get('format'));
  }.property('date')
});
