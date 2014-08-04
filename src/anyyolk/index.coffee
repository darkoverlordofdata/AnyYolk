module.exports = class anyyolk


  @JST: {} # JavaScript Templates
  
  # == Entry Point ==
  #   * This is the main entry point to the game, it
  #   * initialializes all necessary elements to run the game 
  # 
  @start: (Q, id) ->
  
    gets = []
    
    # Templates to load:
    [ 'cloud'
      'credits'
      'egg'
      'game_level'
      'game_lives'
      'game_over'
      'game_score'
      'highscore'
      'menu'
      'score'
      'sun'
      'tile_pair'
      'tree'
      ].forEach (name) ->
        gets.push $.get "views/#{name}.html", (template) ->
          anyyolk.JST[name] = _.template(String(template))

    Q.all(gets).done ->
    
      # Create the model
      model = new anyyolk.GameState()

      # Create the stage
      new anyyolk.Stage(model: model).render()

      # Create all the scenes
      new anyyolk.MenuScene(model: model)
      new anyyolk.GameScene(model: model)
      new anyyolk.GameOverScene(model: model)
      new anyyolk.HighscoreScene(model: model)
      new anyyolk.CreditsScene(model: model)

      # Display the menu
      model.set "scene", "menu"

      # disable dragging and selecting actions
      $(id).on "dragstart selectstart", "*", (event) ->
        false


      # disable scrolling on smartphones
      document.ontouchmove = (e) ->
        e.preventDefault()
        

  @get: (name) ->
    templates[name]
    
  # Generates the appropriate css browser prefix
  @bp: ->
    bp = ""
    bp = "-webkit-"
    if $.browser?
      if $.browser.webkit
        bp = "-webkit-"
      else bp = "-moz-"  if $.browser.mozilla
    
    bp

  @isSupported: ->
    if $.browser?
      not ($.browser.msie and parseInt($.browser.version) < 10)
    else true


  # Executes the function on the next tick. This means
  #   * it will run after the current execution flow is completed
  @nextTick: (func) ->
    setTimeout func, 0


  # Generates a touch or click up event name based on the device
  @clickUpOrTouch: (func) ->
    (if "ontouchstart" of window then "touchstart" else "mouseup")


  # Generates a touch or click down event name based on the device
  @clickDownOrTouch: (func) ->
    (if "ontouchstart" of window then "touchstart" else "mousedown")


require './GameState'
require './EggModel'
require './EggView'
require './Stage'
require './MenuScene'
require './GameScene'
require './GameOverScene'
require './HighscoreScene'
require './CreditsScene'

# Spin.js jQuery plugin
$::spin = (opts) ->
  @each ->
    $this = $(this)
    data = $this.data()
    if data.spinner
      data.spinner.stop()
      delete data.spinner
    if opts isnt false
      data.spinner = new Spinner($.extend(
        color: $this.css("color")
      , opts)).spin(this)

  this
