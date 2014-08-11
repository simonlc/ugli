EXPLANATIONS = {
  singleplayer: '''
    Clearing rows scores points,
    but as you play, the size of the blocks you get increases,
    Get the highest score you can before topping out!
  '''
  battle: '''
    Clearing rows increases the sizes of the blocks your opponent gets.
    Make your opponent top out before you do!
  '''
  race: '''
    Face off against up to four other players!
    Score more points than your opponents in the available time.
  '''
}

MAX_PLAYERS = {
  singleplayer: 1
  battle: 2
  race: 5
}

ROUND_DURATIONS = {
  battle: 1000*60*6
  race: 1000*60*2
}


class @CombinosBase
  @game_types = (do (game_type for game_type of EXPLANATIONS).sort)
  @multiplayer_types = @game_types.filter (type) -> type != 'singleplayer'

  @between_round_duration = 1000*30

  @description: (game_type) ->
    (do game_type.charAt(0).toUpperCase) + (game_type.slice 1)

  @explanation: (game_type) ->
    EXPLANATIONS[game_type]

  @max_players: (game_type) ->
    MAX_PLAYERS[game_type]

  @round_duration: (game_type) ->
    ROUND_DURATIONS[game_type]
