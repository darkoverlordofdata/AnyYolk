# == Egg View ==
#   * This view handles the rendering of eggs,
#   * It is backed by it's own model. 

anyyolk = require('../anyyolk')

class anyyolk.EggView extends Backbone.View

  className: "egg"
  spriteClass: ".egg_sprite_"
  eggTemplate: _.template($("#_egg").html())
  scene: null # The scene the egg view is on
  events:
    webkitTransitionEnd: "handleTransitionEnded"
    mozTransitionEnd: "handleTransitionEnded"
    transitionend: "handleTransitionEnded"

  initialize: =>
    @scene = @options.scene
    @gameState = @options.gameState
    @$el.on Utils.clickDownOrTouch(), @nextSprite
    @model.on "change:spriteIndex", @renderSprites
    @model.on "fly", @renderFlying
    @model.on "break", @renderBreaking


  # Display the next sprite by delegating to the model who triggers a change event
  nextSprite: =>
    unless @model.isSafe()
      @model.nextSprite()
      false


  # This renders the egg view by calculating the animation delay and speed and 
  #       appending the view to the scene. Should only be rendered at the beginning 
  #       of a level, not during. 
  render: =>
    @renderSprites()

    # The intermission allows for the delay used to show the level label
    intermission = 3.5
    delay = undefined
    if @model.get("collectionIndex") is 1
      delay = intermission
    else
      delay = (Math.random() * 6 + 3) / @gameState.get("speedX") + (2 * @model.get("collectionIndex")) + intermission
    speed = 100 * @gameState.get("speedX") + Math.random() * 100 - 50 # in px/s, 100*multiplier +-50
    left = Math.random() * ($(window).width() - 100) + 30 # keep egg completely in window
    top = $("#stage").height() - 220 # keep egg just above screen
    @$el.css Utils.bp() + "transition-delay", delay + "s"
    @$el.css Utils.bp() + "transition-duration", $(window).height() / speed + "s"
    @$el.css Utils.bp() + "transition-property", "top opacity"
    @$el.css Utils.bp() + "transition-timing-function", "linear"
    @$el.css "left", left + "px"
    @scene.append @$el

    # Start animation
    Utils.nextTick =>
      @$el.css "top", top + "px"



  # Render the next sprite by re generating the template 
  renderSprites: =>
    @$el.html @eggTemplate(spriteIndex: @model.get("spriteIndex"))


  # Render the breaking state (animation of egg rolling sideways) 
  renderBreaking: =>
    @$el.addClass("cracked").addClass "disabled"
    @$el.css Utils.bp() + "transition-delay", "0s"
    @$el.css Utils.bp() + "transition-duration", "0.2s"


  # Render the broken state. Changes the image and fades out the egg 
  renderHidding: =>
    @$el.addClass "broken"
    @$el.css Utils.bp() + "transition-delay", "1s"
    @$el.css Utils.bp() + "transition-duration", "0.5s"
    @$el.css Utils.bp() + "transition-property", "opacity"
    @$el.css Utils.bp() + "transition-timing-function", "linear"
    @$el.css "opacity", 0


  # Render the flying state when the egg was clicked enough times 
  renderFlying: =>
    @$el.addClass "flying"
    @$el.css Utils.bp() + "transition-delay", "0s"
    @$el.css Utils.bp() + "transition-duration", "1s"
    @$el.css Utils.bp() + "transition-property", "top"
    @$el.css Utils.bp() + "transition-timing-function", "linear"


  # Remove this view from the DOM 
  renderRemove: =>
    @remove()


  # Handle a CSS transition ending. Based on property we identify if the
  #       transition was falling, breaking or hiding the egg and render the next
  #       state 
  handleTransitionEnded: (e) =>
    if e.originalEvent.propertyName is "opacity" # hidding completed
      @renderRemove()
    else if e.originalEvent.propertyName is "top" # falling completed
      @model.eggHitGround()
    # breaking completed
    else @renderHidding()  if e.originalEvent.propertyName is Utils.bp() + "transform" or "transform"
    false

