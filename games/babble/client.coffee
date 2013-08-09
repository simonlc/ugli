# The UGLI framework maintains this client's @ugli member variable, which is
# a read-only client-side game context.
#
# This context stores the following data, all of which is read-only:
#   players: list of users currently in the game
#   view: partial client view of game state
#
# In addition, the context provides these UGLI framework helper methods:
#   send: (message) -> send EJSON-able message to server's handle_client_message

class @BabbleClient
  @make_config_ui: (container, start_game) ->
    # populate the provided jquery-wrapped div with pre-game config ui.
    # the ui should call start_game(config) with JSON-able game parameters
    # that will be passed server.initialize_state.
    container.append(
      'Number of rounds: '
      $ '<input type="number" min="1" max="20" value="5"/>'
      ' '
      $('<button/>').text('Play!').on 'click', ->
        start_game num_rounds: parseInt container.find('input').val()
    )

  constructor: (@ugli, @container) ->
    # populate the provided jquery-wrapped div with the game ui.
    @container.append(
      $('<div class="inner-container"/>').append(
        $('<h1 class="getready"/>')
        $('<div class="compose-cont"/>').append(
          $('<div class="words"/>')
          $('<div style="clear:both"/>').append(
            'Compose a sentence using the words above! '
            $('<input class="sentence" size="100"/>')
              .on('input', => @_check_input())
            $('<div class="violations"/>')
            $('<div/>').append(
              'Your submission: '
              $('<span class="your-submission"/>')
            )
          )
        ).hide()
        $('<div class="submissions-cont"/>').append(
          $('<h1/>').text "Time's up!"
          "Vote on the submissions:"
          $('<ul class="submissions"/>').on 'click', 'button', ->
            ugli.send ['vote', $(@).closest('li').find('.submission').text()]
        ).hide()
        $('<pre class="params" style="color:#999;font-size:80%;max-height:300px;overflow:auto"/>')
      )
    )
    @round_words_shuffled = {}
    @handle_update()

  _check_input: ->
    sentence = @container.find('.sentence').val()
    [valid, used_word_counts, messages] =
        validate_sentence @ugli.view.words, sentence
    @container.find('.submit').toggle valid
    @container.find('.violations')
      .empty()
      .append(($('<div>').text m for m in messages)...)
      .toggle(not valid)
    @container.find('.words .word').each ->
      e = $(@)
      e.toggleClass 'used', used_word_counts[e.text()]-- > 0
    if valid and not sentence.match(/^\s*$/) and sentence isnt @ugli.view.submission
      @ugli.send ['submit_sentence', sentence]

  handle_update: ->
    # called to notify client that ugli.state has changed.
    @container.find('.params').text JSON.stringify @ugli.view, undefined, 3

    @container.find('.getready')
      .text("Get ready for round #{@ugli.view.round}!")
      .toggle(@ugli.view.phase is 'countdown')

    @container.find('.compose-cont').toggle @ugli.view.phase is 'compose'
    if @ugli.view.phase is 'compose'
      words = @round_words_shuffled[@ugli.view.round] ?= _.shuffle @ugli.view.words
      @container.find('.words').empty().append(
        ($('<div class="word">').text(w) for w in words)...
      )
    @container.find('.your-submission').text(@ugli.view.submission ? '')
      .closest('div').toggle @ugli.view.submission?

    @container.find('.submissions-cont').toggle @ugli.view.phase is 'voting'
    @container.find('.submissions').empty().append((
      $('<li/>').append(
        $('<span class="submission"/>').text s
        $('<button/>').text 'vote'
      ) for s in @ugli.view.sentences ? [])...
    )

    @_check_input()
