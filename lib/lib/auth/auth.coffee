Observatory = @Observatory ? {}

# quick and dirty authorization
# user - currently logged in user or null
# action - name of the action they want to run
# in the future, need some role-based checking, action map etc
# for now - only checking for the administrator role
# to address mind-boggling @userId issue, call as Observatory.canRun.call this !!! in publish functions
Observatory.canRun = (uid, action = 'view')->
#return true if Observatory.isLocalhost
  res = false
  if uid?
    user = Meteor.users.findOne(uid)
  else
    try
      user = (Meteor.users.findOne(_id: @userId) ? Meteor.user()) if not uid?
    catch err
#console.log @userId
#console.log user
  res = true if user?.profile?.observatoryProfile?.role is "administrator" or user?.securityProfile?.observatoryProfile?.role is "administrator"
  #console.log "Result of running canRun is #{res}"
  res
