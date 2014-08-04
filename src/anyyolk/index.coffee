
module.exports = class anyyolk


  @start: ($next) ->
  
    anyyolk.JST = {}
    deferreds = []
    views = [
      'cloud'
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
    ]

#    path = location.pathname.replace('/index.html', '')
#    console.log 'path = '+path
#    
#    $.each views, (index, name) =>
#      console.log "#{location.origin}#{path}/views/#{name}.html"
#      deferreds.push $.get "#{location.origin}#{path}/views/#{name}.html", (template) =>
#        anyyolk.JST[name] = _.template(String(template))
#
#    $.when.apply(null, deferreds).done $next

    $.each views, (index, name) =>
      deferreds.push $.get "views/#{name}.html", (template) =>
        anyyolk.JST[name] = _.template(String(template))

    $.when.apply(null, deferreds).done $next


  @get: (name) ->
    templates[name]
    
  # Generates the appropriate css browser prefix
  @bp: ->
    bp = ""
    if $.browser.webkit
      bp = "-webkit-"
    else bp = "-moz-"  if $.browser.mozilla
    bp

  @isSupported: ->
    not ($.browser.msie and parseInt($.browser.version) < 10)


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
