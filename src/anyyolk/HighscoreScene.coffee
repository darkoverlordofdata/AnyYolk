
# == Scenes ==
#   * Scenes represent screens in the game. They are added and
#   * removed as the player navigates the game.
#   

anyyolk = require('../anyyolk')

# Scene for the highscore, accessed from the menu button 
class anyyolk.HighscoreScene extends Backbone.View

  className       : "highscore_scene"
  sceneName       : "highscore"
  events:
    animationend          : "cleanUp"
    webkitAnimationEnd    : "cleanUp"
    mozAnimationEnd       : "cleanUp"

  initialize: =>
    @model.on "change:scene", @renderSceneChange
    @model.get("highscoreCollection").on "reset", @renderScoreCollection
    @$el.on anyyolk.clickUpOrTouch(), ".back_button", @handleBackButton
    @render()  if @model.get("currentScene") is @sceneName

  handleBackButton: (e) =>
    @$(".back_button").addClass "disabled"
    @model.set "scene", "menu"
    false

  renderSceneChange: (model, scene) =>
    if model.previous("scene") is @sceneName
      @renderRemoveScene()
    else @render()  if scene is @sceneName
    this

  render: =>

    # render view
    @$el.html anyyolk.JST._highscore()

    # fetch collection
    @model.get("highscoreCollection").fetch()

    # Add loading spinner
    @$(".highscore").spin
      length: 9
      radius: 10
      lines: 12
      width: 4
      color: "#fff"


    # Add scene to the stage
    $("#stage").append @$el
    this

  renderScoreCollection: =>
    @model.get("highscoreCollection").each (score, index) =>
      @renderScore score, index

    $(".highscore .spinner").remove()
    this

  renderScore: (score, index) =>
    @$("#score_table tbody").append anyyolk.JST._score
      score: score
      index: index
    

  renderRemoveScene: =>

    # Setup classes for removal
    @$(".menu_item").addClass "removal"
    @$(".highscore").addClass "removal"

    # Bind removal animations
    @$(".menu_item").css anyyolk.bp() + "animation-name", "raiseMenu"
    @$(".highscore").css anyyolk.bp() + "animation-name", "raiseScores"

  cleanUp: (e) =>
    @$el.empty()  if @model.get("scene") isnt @sceneName and $(e.target).hasClass("highscore")

