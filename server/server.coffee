Meteor.startup ->
  core = new UGLICore


  Meteor.publish 'current_room', ->
    Rooms.publish_current_room @userId

  do Rooms.create_test_data
  Meteor.publish 'game_rooms', ->
    do Rooms.publish_game_rooms

  Meteor.publish 'chats', (room_id) ->
    core.publish_chats @userId, room_id


  Meteor.methods
    'heartbeat': ->
      core.heartbeat @userId

    'create_game': (config) ->
      throw new NotImplementedError

    'join_game': (room_id) ->
      throw new NotImplementedError

    'leave_game': (room_id) ->
      throw new NotImplementedError

    'send_chat': (room_id, message) ->
      core.send_chat @userId, room_id, message

    'send_game_message': (room_id, message) ->
      core.handle_message @userId, room_id, message


  cleanup = ->
    core.mark_idle_users Common.idle_timeout

  Meteor.setInterval cleanup, Common.idle_timeout
