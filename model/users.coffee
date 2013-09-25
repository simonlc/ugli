# This is the core Meteor users collection, so we don't touch its global fields.
# Instead, we modify members of the fields subdocument:
#   fields.active: bool
#   fields.heartbeat: ts

class @Users extends Collection
  @set_schema
    collection: Meteor.users
    fields: [
      'fields.active',
      'fields.heartbeat',
    ]
    indices: [
      {columns: 'fields.active', options: sparse: true}
    ]

  # Compute a list of fields to publish. We shouldn't broadcast passwords!
  # We also shouldn't broadcast heartbeats because they cause unneeded updates.
  @public_fields = username: 1
  for field in @fields
    if field not in ['fields.active', 'fields.heartbeat']
      @public_fields[field] = 1

  @publish: (user_id) ->
    @find({'fields.active': true}, fields: @public_fields)

  @heartbeat = (user_id) ->
    check(user_id, String)
    @update(
      {_id: user_id},
      $set:
        'fields.heartbeat': new Date().getTime()
        'fields.active': true
    )
    Rooms.join_room user_id, Rooms.get_lobby()?._id

  @mark_idle_users = (idle_timeout) ->
    check(idle_timeout, Number)
    idle_time = new Date().getTime() - idle_timeout
    users = @find(
      'fields.active': true
      'fields.heartbeat': $lt: idle_time
    ).fetch()
    user_ids = (user._id for user in users)
    # Boot users from rooms first. If this step fails, they'll stay active.
    Rooms.boot_users user_ids
    Users.update({_id: $in: user_ids}, $set: 'fields.active': false)
