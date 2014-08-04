
# == Scenes ==
#   * Scenes represent screens in the game. They are added and
#   * removed as the player navigates the game.
#   

# Scene displayed once the player loses the game 
anyyolk = require('../anyyolk')

class anyyolk.GameOverScene extends Backbone.View

  @Congrats = [
    "Not bad"
    "Good"
    "Great"
    "Fantastic"
    "Smashing!"
    "Amazing!"
    "Flying High"
    "Ridiculous!"
    "Extraordinary!"
    "Monstrous!!"
  ]

  className   : "game_over_scene"
  sceneName   : "game_over"
  submitted   : false
  events:
    animationend          : "cleanUp"
    webkitAnimationEnd    : "cleanUp"
    mozAnimationEnd       : "cleanUp"

  initialize: =>
    @model.on "change:scene", @renderSceneChange
    @$el.on anyyolk.clickUpOrTouch(), ".menu_button", @handleMenuButton
    @$el.on anyyolk.clickUpOrTouch(), ".replay_button", @handleReplayButton
    @$el.on anyyolk.clickUpOrTouch(), ".facebook_button", @handleFacebookButton

  handleMenuButton: (e) =>
    @$(".menu_item").addClass "disabled"
    @model.set "scene", "menu"

  handleReplayButton: (e) =>
    @$(".menu_item").addClass "disabled"
    @model.set "scene", "game"

  handleFacebookButton: (e) =>
    $(".fb_content").hide()
    $(".facebook_button").addClass("disabled").empty().spin
      length: 5
      radius: 5
      lines: 8
      width: 3
      color: "#fff"

    if Parse.User.current()
      @saveHighScore()
    else
      Parse.Facebookanyyolk.logIn null,
        success: (user) =>

          # If it's a new user, let's fetch their name from FB
          unless user.existed()

            # We make a graph request
            FB.api "/me", (response) =>
              unless response.error

                # We save the data on the Parse user
                user.set "displayName", response.name
                user.save null,
                  success: (user) =>

                    # And finally save the new score
                    @saveHighScore()

                  error: (user, error) =>
                    console.log "Oops, something went wrong saving your name."

              else
                console.log "Oops something went wrong with facebook."


          # If it's an existing user that was logged in, we save the score
          else
            @saveHighScore()

        error: (user, error) =>
          console.log "Oops, something went wrong."



  # Create highscore object and save to Parse using Cloud Code 
  saveHighScore: =>

    # Generate score hash (this makes it harder for hackers to 
    # submit an arbitrarily high value)
    submission = score: @model.getScoreSubmission()

    # Submit highscore using Cloud Code
    Parse.Cloud.run "submitHighscore", submission,
      success: (result) =>
        @submitted = true
        @$(".facebook_button").html "Submitted!"

      error: (error) =>
        @submitted = true
        @$(".facebook_button").html(" X Try Again...").removeClass "disabled"


  renderSceneChange: (model, scene) =>
    if model.previous("scene") is @sceneName
      @renderRemoveScene()
    else @render()  if scene is @sceneName
    this

  render: =>
    congratsIndex = (if @model.get("level") > GameOverScene.Congrats.length then GameOverScene.Congrats.length - 1 else @model.get("level") - 1)
    @$el.html anyyolk.JST.game_over
      score     : @model.get("score")
      congrats  : GameOverScene.Congrats[congratsIndex]
    
    $("#stage").append @$el

  renderRemoveScene: =>

    # Setup classes for removal
    @$(".menu_item").addClass "removal"
    @$(".summary").addClass "removal"

    # Bind removal animations
    @$(".menu_item").css anyyolk.bp() + "animation-name", "raiseMenu"
    @$(".summary").css anyyolk.bp() + "animation-name", "raiseScores"

  cleanUp: (e) =>
    @$el.empty()  if @model.get("scene") isnt @sceneName and $(e.target).hasClass("summary")

