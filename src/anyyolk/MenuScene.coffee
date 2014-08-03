# == Scenes ==
#   * Scenes represent screens in the game. They are added and
#   * removed as the player navigates the game.
#   
anyyolk = require('../anyyolk')

# Scene for the main menu displayed on launch 
class anyyolk.MenuScene extends Backbone.View

  className   : "menu_scene"
  template    : _.template($("#_menu").html())
  sceneName   : "menu" # name used to show/hide scene
  events:
    "animationend .title"         : "cleanUp"
    "webkitAnimationEnd .title"   : "cleanUp"
    "mozAnimationEnd .title"      : "cleanUp"

  initialize: =>
    @model.on "change:scene", @renderSceneChange # show/hide scene based on sceneName

    # Add click or touch event depending on device
    @$el.on anyyolk.clickUpOrTouch(), "#play_button", @handlePlayButton
    @$el.on anyyolk.clickUpOrTouch(), "#highscore_button", @handleHighscoreButton
    @$el.on anyyolk.clickUpOrTouch(), "#credits_button", @handleCreditsButton
    this


  # Go to "game" scene 
  handlePlayButton: (e) =>
    @$(".menu_item").addClass "disabled"
    @model.set "scene", "game"
    false


  # Go to "highscore" scene 
  handleHighscoreButton: (e) =>
    @$(".menu_item").addClass "disabled"
    @model.set "scene", "highscore"
    false


  # Go to "credits" scene 
  handleCreditsButton: (e) =>
    @$(".menu_item").addClass "disabled"
    @model.set "scene", "credits"
    false


  # Check if this scene should show or hide 
  renderSceneChange: (model, scene) =>
    if model.previous("scene") is @sceneName
      @renderRemoveScene()
    else @render()  if scene is @sceneName
    this


  # Show this scene 
  render: =>
    @$el.html @template()
    $("#stage").append @$el
    this


  # Hide this scene 
  renderRemoveScene: =>

    # Setup classes for removal
    @$(".title").removeClass("display").addClass "removal"
    @$(".menu_item").addClass "removal"

    # Bind removal animations
    @$(".title").css anyyolk.bp() + "animation-name", "raiseTitle"
    @$(".menu_item").css anyyolk.bp() + "animation-name", "raiseMenu"
    this


  # After removal animation, delete from DOM 
  cleanUp: (e) =>
    @$el.empty()  if @model.get("scene") isnt @sceneName and $(e.target).hasClass("title")
    false

