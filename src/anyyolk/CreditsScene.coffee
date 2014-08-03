
# == Scenes ==
#   * Scenes represent screens in the game. They are added and
#   * removed as the player navigates the game.
#   
anyyolk = require('../anyyolk')

# Scene for the credits, accessed from the menu button 
class anyyolk.CreditsScene extends Backbone.View

  className   : "credits_scene"
  sceneName   : "credits"
  events:
    animationend        : "cleanUp"
    webkitAnimationEnd  : "cleanUp"
    mozAnimationEnd     : "cleanUp"

  initialize: =>
    @model.on "change:scene", @renderSceneChange
    @$el.on anyyolk.clickUpOrTouch(), ".back_button", @handleBackButton

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
#    @$el.html @template()
    @$el.html anyyolk.JST._credits()

    # Add scene to the stage
    $("#stage").append @$el
    this

  renderRemoveScene: =>

    # Setup classes for removal
    @$(".credits").addClass "removal"
    @$(".back_button").addClass "removal"

    # Bind removal animations
    @$(".credits").css anyyolk.bp() + "animation-name", "raiseMenu"
    @$(".back_button").css anyyolk.bp() + "animation-name", "raiseMenu"

  cleanUp: (e) =>
    @$el.empty()  if @model.get("scene") isnt @sceneName and $(e.target).hasClass("credits")

