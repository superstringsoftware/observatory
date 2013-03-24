Template.observatoryjsMonitoring.events
  'click #btnTestStuff':->
    Meteor.call "_observatoryGetOpenSockets", (err, res)->
      console.dir res

    Meteor.call "_observatoryGetCurrentServer", (err, res)->
      console.log "Meteor.call _observatoryGetCurrentServer"
      console.dir res