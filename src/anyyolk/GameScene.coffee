# == Scenes ==
#   * Scenes represent screens in the game. They are added and
#   * removed as the player navigates the game.
#   
anyyolk = require('../anyyolk')

# Scene for the game itself, displayed when "Play" is clicked 
class anyyolk.GameScene extends Backbone.View

  className: "game_scene"
  events:
    animationend: "cleanUp"
    webkitAnimationEnd: "cleanUp"
    mozAnimationEnd: "cleanUp"

  scoreTemplate: _.template($("#_game_score").html())
  levelTemplate: _.template($("#_game_level").html())
  livesTemplate: _.template($("#_game_lives").html())
  sceneName: "game"
  initialize: =>
    @eggViews = []
    @$el.on Utils.clickUpOrTouch(), ".back_button", @handleBackButton
    @model.on "change:scene", @renderSceneChange
    @model.get("eggCollection").on "add", @renderAddEgg
    @model.on "change:score", @renderScore
    @model.on "change:lives", @renderLives
    @model.on "change:level", @renderLevel
    @model.on "change:level", @renderLevelLabel

  handleBackButton: (e) =>
    @$(".back_button").addClass "disabled"
    @model.set "scene", "menu"

  renderSceneChange: (model, scene) =>
    if model.previous("scene") is @sceneName
      @renderRemoveScene()
    else @render()  if scene is @sceneName
    this

  render: =>

    # Reset game data like score, lives, etc.
    @model.resetGameData()

    # Remove previous HUD
    @$("#hud").remove()
    @$el.append "<div id='hud'></div>"

    # Render templates
    @renderLevel()
    setTimeout (=>
      @renderLevelLabel()
    ), 1200
    @renderScore()
    @renderLives()
    @renderBackButton()
    @renderEggs()

    # Add to stage if necessary
    $("#stage").append @$el  if $("#stage ." + @className).length <= 0
    this

  renderLevel: =>
    if @$("#game_level").length > 0
      @$("#game_level").replaceWith @levelTemplate(level: @model.get("level"))
    else
      @$("#hud").append @levelTemplate(level: @model.get("level"))
    this

  renderLevelLabel: =>
    @$el.append "<p class='level_label'>LEVEL " + @model.get("level") + "<br>GET READY!</p>"
    setTimeout (=>
      @$(".level_label").addClass "removal"
    ), 3000
    setTimeout (=>
      @$(".level_label").remove()
    ), 3300
    this

  renderScore: =>
    if @$("#game_score").length > 0
      @$("#game_score").replaceWith @scoreTemplate(score: @model.get("score"))
    else
      @$("#hud").append @scoreTemplate(score: @model.get("score"))
    this

  renderLives: =>
    if @$("#game_lives").length > 0
      @$("#game_lives").replaceWith @livesTemplate(lives: @model.get("lives"))
    else
      @$("#hud").append @livesTemplate(lives: @model.get("lives"))
    this

  renderBackButton: =>
    if @$(".back_button").length > 0
      @$(".back_button").replaceWith "<div class='back_button'>X</div>"
    else
      @$el.append "<div class='back_button'>X</div>"
    this

  renderEggs: =>
    @model.addEggs()
    this

  renderAddEgg: (eggModel, collection, options) =>
    eggView = new anyyolk.EggView(
      model: eggModel
      gameState: @model
      scene: @$el
    )
    eggView.render()
    @eggViews.push eggView
    this

  renderRemoveScene: =>

    # Animate the HUD dissapearing
    @$(".back_button").css Utils.bp() + "animation-name", "xRaise"
    @$("#hud p").css Utils.bp() + "animation-name", "removeHUD"
    @$(".egg").css Utils.bp() + "transition-duration", "0.3s"

    # Remove all egg views and their models
    _.each @eggViews, (eggView) =>
      eggView.renderRemove()

    @model.get("eggCollection").reset()
    this


  # Do any remaining clean up after animations triggered
  #       in renderRemoveScene are completed. 
  cleanUp: (e) =>
    @$el.empty()  if @model.get("scene") isnt @sceneName and $(e.target).hasClass("back_button")
    false

