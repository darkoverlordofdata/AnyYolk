# == Stage ==
#   * The stage represents the background of the game. It is
#   * always displayed and does not need to be added or removed
#   * at any point 
anyyolk = require('../anyyolk')

class anyyolk.Stage extends Backbone.View

  el              : "#stage"
  tileTemplate    : _.template($("#_tile_pair").html())
  treeTemplate    : _.template($("#_tree").html())
  sunTemplate     : _.template($("#_sun").html())
  cloudTemplate   : _.template($("#_cloud").html())


  # The render function delegates to a render function for each "element" 
  render: =>
    @$el.css "height", $(window).height()
    @renderSun()
    @renderTrees()
    @renderTiles()
    @renderClouds()


  # Render the ground, simply an image 
  renderTiles: =>
    @$(".tile").remove()
    @$el.append @tileTemplate()


  # Render the sun, simply an image with a CSS keyframe 
  renderSun: =>
    @$(".sun").remove()
    @$el.append @sunTemplate()


  # Render the trees, amount, position and image randomized based on width 
  renderTrees: =>
    numTrees = Math.ceil($(window).width() / 200)
    @$(".tree").remove()

    # for small screens we place two trees manually
    if numTrees <= 2
      @$el.append @treeTemplate
        treeNum     : 3
        leftValue   : -100
      
      @$el.append @treeTemplate
        treeNum     : 1
        leftValue   : 120
      
    else
      i = 0

      while i < numTrees
        left = Math.random() * (200) + i * 200
        @$el.append @treeTemplate # -1 for treeNum tells the template to randomize
          treeNum     : -1
          leftValue   : left - 300
        
        i++


  # Render the floating clouds, position, amount and size randomized 
  renderClouds: =>
    numClouds = Math.ceil($(window).width() / 200)
    numClouds = (if numClouds < 2 then 2 else numClouds)
    i = 0

    while i < numClouds
      top = Math.random() * 50
      delay = Math.random() * 8 - 4 + (10 * i) # each cloud is spaced apart by 6-14s
      speed = 20 # in px/s
      dir = (if Math.floor(Math.random() * 2) < 1 then "left" else "right")
      @$el.append @cloudTemplate
        bp          : anyyolk.bp
        delay       : delay
        direction   : dir
        duration    : $(window).width() / speed
        topValue    : top
      
      i++
