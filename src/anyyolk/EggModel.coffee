# == Egg Model ==
#   * Model used to back an Egg View. Manage the sprite and current
#   * state of each egg. 

anyyolk = require('../anyyolk')
#
class anyyolk.EggModel extends Backbone.Model

  # The number of sprites for eggs
  @NumSprites = 5


  defaults:
    spriteIndex       : 1
    collectionIndex   : 0

  # Increases the .png index to show the new sprite image 
  nextSprite: =>

    # increment
    @set "spriteIndex", @get("spriteIndex") + 1
    # check if new sprite is safe
    @trigger "fly", [this]  if @isSafe() # trigger success event


  # Checks if the egg is currently broken (at last sprite) 
  isSafe: =>
    @get("spriteIndex") >= EggModel.NumSprites


  # Event triggered when egg hits the ground 
  eggHitGround: =>
    @trigger "break", [this]  unless @isSafe() # trigger failure event

