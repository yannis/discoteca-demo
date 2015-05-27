import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  artist: DS.belongsTo('artist'),
  releasedOn: DS.attr('date'),
  artworkUrl: DS.attr('string')
});
