import ArtistsBaseController from './base';

export default ArtistsBaseController.extend({
  actions: {
    cancel: function() {
      this.model.rollback();
      this.transitionToRoute('artists');
    }
  }
});
