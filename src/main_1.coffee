$ ->
  
  # == Entry Point ==
  #   * This is the main entry point to the game, it
  #   * initialializes all necessary elements to run the game 
  Game = initialize: ->
    if Utils.isSupported()
      
      # Create the model
      model = new GameState()
      
      # Create the stage
      new Stage(model: model).render()
      
      # Create all the scenes
      new MenuScene(model: model)
      new GameScene(model: model)
      new GameOverScene(model: model)
      new HighscoreScene(model: model)
      new CreditsScene(model: model)
      
      # Display the menu
      model.set "scene", "menu"
      
      # disable dragging and selecting actions
      $("#stage").on "dragstart selectstart", "*", (event) ->
        false

      
      # disable scrolling on smartphones
      document.ontouchmove = (e) ->
        e.preventDefault()
    else
      $("#unsupported").show()

  
  ###
  Models ****
  ###
  
  # == Game State =
  #   * This model is transient and represents the state of the
  #   * game. It is used to facilitate communication between the views,
  #   * especially changing scenes and sharing game stats (score, 
  #   * level, etc). 
  GameState = Backbone.Model.extend(
    defaults:
      scene: ""
      eggCollection: null
      speedX: 1

    initialize: ->
      _.bindAll this
      
      # This collection will store the egg models when they are on screen
      @set "eggCollection", new Backbone.Collection()
      
      # This collection is used in the highscore page to facilitate the query to Parse
      query = new Parse.Query("HighScore")
      query.descending "score"
      query.include "player"
      query.limit 10
      @set "highscoreCollection", query.collection()
      
      # Initialize the game data (score, level, etc)
      @resetGameData()
      
      # Events to manage th game data
      @get("eggCollection").on "fly", @incrementScore
      @get("eggCollection").on "break", @decrementLife
      @get("eggCollection").on "fly break", @cleanUpEgg
      @get("eggCollection").on "remove", @incrementLevel

    
    # Increases the user's score by 1 
    incrementScore: ->
      @set "score", @get("score") + 1

    
    # Decreases the user's lives by 1 
    decrementLife: ->
      @set "lives", @get("lives") - 1
      @validateAlive()

    
    # Increment the user's level by 1 and increases speed multiplier 
    incrementLevel: ->
      if @get("eggCollection").length <= 0
        @set "level", @get("level") + 1
        @set "speedX", @get("speedX") + 0.25
        @addEggs()

    
    # Checks if the user is still alive. If not, changes scene. 
    validateAlive: ->
      @set "scene", "game_over"  if @get("lives") <= 0

    
    # Add 10 eggs for the current level 
    addEggs: ->
      numEggs = 10
      i = 0

      while i < numEggs
        @get("eggCollection").add new EggModel(collectionIndex: i)
        i++

    
    # Remove broken or saved eggs from the model 
    cleanUpEgg: (eggModel) ->
      @get("eggCollection").remove eggModel

    
    # Resets the game's data (score, level, etc) for a new game 
    resetGameData: ->
      @set GameState.DefaultGameData

    
    # We hash the score before sending it to Cloud Code. This is an 
    #       efficient way to secure your highscore (though nothing is full proof) 
    getScoreSubmission: ->
      ((@get("level") * 362) << 5) + "." + ((@get("score") * 672) << 4)
  ,
    
    # The default game data used for a new game 
    DefaultGameData:
      score: 0
      lives: 3
      level: 1
      speedX: 1
  )
  
  # == Egg Model ==
  #   * Model used to back an Egg View. Manage the sprite and current
  #   * state of each egg. 
  EggModel = Backbone.Model.extend(
    defaults:
      spriteIndex: 1
      collectionIndex: 0

    initialize: ->
      _.bindAll this

    
    # Increases the .png index to show the new sprite image 
    nextSprite: ->
      
      # increment
      @set "spriteIndex", @get("spriteIndex") + 1
      # check if new sprite is safe
      @trigger "fly", [this]  if @isSafe() # trigger success event

    
    # Checks if the egg is currently broken (at last sprite) 
    isSafe: ->
      @get("spriteIndex") >= EggModel.NumSprites

    
    # Event triggered when egg hits the ground 
    eggHitGround: ->
      @trigger "break", [this]  unless @isSafe() # trigger failure event
  ,
    
    # The number of sprites for eggs
    NumSprites: 5
  )
  
  ###
  Views ****
  ###
  
  # == Egg View ==
  #   * This view handles the rendering of eggs,
  #   * It is backed by it's own model. 
  EggView = Backbone.View.extend(
    className: "egg"
    spriteClass: ".egg_sprite_"
    eggTemplate: _.template($("#_egg").html())
    scene: null # The scene the egg view is on
    events:
      webkitTransitionEnd: "handleTransitionEnded"
      mozTransitionEnd: "handleTransitionEnded"
      transitionend: "handleTransitionEnded"

    initialize: ->
      _.bindAll this
      @scene = @options.scene
      @gameState = @options.gameState
      @$el.on Utils.clickDownOrTouch(), @nextSprite
      @model.on "change:spriteIndex", @renderSprites
      @model.on "fly", @renderFlying
      @model.on "break", @renderBreaking

    
    # Display the next sprite by delegating to the model who triggers a change event
    nextSprite: ->
      unless @model.isSafe()
        @model.nextSprite()
        false

    
    # This renders the egg view by calculating the animation delay and speed and 
    #       appending the view to the scene. Should only be rendered at the beginning 
    #       of a level, not during. 
    render: ->
      self = this
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
      Utils.nextTick ->
        self.$el.css "top", top + "px"


    
    # Render the next sprite by re generating the template 
    renderSprites: ->
      @$el.html @eggTemplate(spriteIndex: @model.get("spriteIndex"))

    
    # Render the breaking state (animation of egg rolling sideways) 
    renderBreaking: ->
      @$el.addClass("cracked").addClass "disabled"
      @$el.css Utils.bp() + "transition-delay", "0s"
      @$el.css Utils.bp() + "transition-duration", "0.2s"

    
    # Render the broken state. Changes the image and fades out the egg 
    renderHidding: ->
      @$el.addClass "broken"
      @$el.css Utils.bp() + "transition-delay", "1s"
      @$el.css Utils.bp() + "transition-duration", "0.5s"
      @$el.css Utils.bp() + "transition-property", "opacity"
      @$el.css Utils.bp() + "transition-timing-function", "linear"
      @$el.css "opacity", 0

    
    # Render the flying state when the egg was clicked enough times 
    renderFlying: ->
      @$el.addClass "flying"
      @$el.css Utils.bp() + "transition-delay", "0s"
      @$el.css Utils.bp() + "transition-duration", "1s"
      @$el.css Utils.bp() + "transition-property", "top"
      @$el.css Utils.bp() + "transition-timing-function", "linear"

    
    # Remove this view from the DOM 
    renderRemove: ->
      @remove()

    
    # Handle a CSS transition ending. Based on property we identify if the
    #       transition was falling, breaking or hiding the egg and render the next
    #       state 
    handleTransitionEnded: (e) ->
      self = this
      if e.originalEvent.propertyName is "opacity" # hidding completed
        self.renderRemove()
      else if e.originalEvent.propertyName is "top" # falling completed
        self.model.eggHitGround()
      # breaking completed
      else self.renderHidding()  if e.originalEvent.propertyName is Utils.bp() + "transform" or "transform"
      false
  )
  
  # == Stage ==
  #   * The stage represents the background of the game. It is
  #   * always displayed and does not need to be added or removed
  #   * at any point 
  Stage = Backbone.View.extend(
    el: "#stage"
    
    # Templates
    tileTemplate: _.template($("#_tile_pair").html())
    treeTemplate: _.template($("#_tree").html())
    sunTemplate: _.template($("#_sun").html())
    cloudTemplate: _.template($("#_cloud").html())
    initialize: ->
      _.bindAll this

    
    # The render function delegates to a render function for each "element" 
    render: ->
      @$el.css "height", $(window).height()
      @renderSun()
      @renderTrees()
      @renderTiles()
      @renderClouds()

    
    # Render the ground, simply an image 
    renderTiles: ->
      @$(".tile").remove()
      @$el.append @tileTemplate()

    
    # Render the sun, simply an image with a CSS keyframe 
    renderSun: ->
      @$(".sun").remove()
      @$el.append @sunTemplate()

    
    # Render the trees, amount, position and image randomized based on width 
    renderTrees: ->
      numTrees = Math.ceil($(window).width() / 200)
      @$(".tree").remove()
      
      # for small screens we place two trees manually
      if numTrees <= 2
        @$el.append @treeTemplate(
          treeNum: 3
          leftValue: -100
        )
        @$el.append @treeTemplate(
          treeNum: 1
          leftValue: 120
        )
      else
        i = 0

        while i < numTrees
          left = Math.random() * (200) + i * 200
          @$el.append @treeTemplate( # -1 for treeNum tells the template to randomize
            treeNum: -1
            leftValue: left - 300
          )
          i++

    
    # Render the floating clouds, position, amount and size randomized 
    renderClouds: ->
      numClouds = Math.ceil($(window).width() / 200)
      numClouds = (if numClouds < 2 then 2 else numClouds)
      i = 0

      while i < numClouds
        top = Math.random() * 50
        delay = Math.random() * 8 - 4 + (10 * i) # each cloud is spaced apart by 6-14s
        speed = 20 # in px/s
        dir = (if Math.floor(Math.random() * 2) < 1 then "left" else "right")
        @$el.append @cloudTemplate(
          delay: delay
          direction: dir
          duration: $(window).width() / speed
          topValue: top
        )
        i++
  )
  
  # == Scenes ==
  #   * Scenes represent screens in the game. They are added and
  #   * removed as the player navigates the game.
  #   
  
  # Scene for the main menu displayed on launch 
  MenuScene = Backbone.View.extend(
    className: "menu_scene"
    events:
      "animationend .title": "cleanUp"
      "webkitAnimationEnd .title": "cleanUp"
      "mozAnimationEnd .title": "cleanUp"

    template: _.template($("#_menu").html())
    sceneName: "menu" # name used to show/hide scene
    initialize: ->
      _.bindAll this
      @model.on "change:scene", @renderSceneChange # show/hide scene based on sceneName
      
      # Add click or touch event depending on device
      @$el.on Utils.clickUpOrTouch(), "#play_button", @handlePlayButton
      @$el.on Utils.clickUpOrTouch(), "#highscore_button", @handleHighscoreButton
      @$el.on Utils.clickUpOrTouch(), "#credits_button", @handleCreditsButton
      this

    
    # Go to "game" scene 
    handlePlayButton: (e) ->
      @$(".menu_item").addClass "disabled"
      @model.set "scene", "game"
      false

    
    # Go to "highscore" scene 
    handleHighscoreButton: (e) ->
      @$(".menu_item").addClass "disabled"
      @model.set "scene", "highscore"
      false

    
    # Go to "credits" scene 
    handleCreditsButton: (e) ->
      @$(".menu_item").addClass "disabled"
      @model.set "scene", "credits"
      false

    
    # Check if this scene should show or hide 
    renderSceneChange: (model, scene) ->
      if model.previous("scene") is @sceneName
        @renderRemoveScene()
      else @render()  if scene is @sceneName
      this

    
    # Show this scene 
    render: ->
      @$el.html @template()
      $("#stage").append @$el
      this

    
    # Hide this scene 
    renderRemoveScene: ->
      
      # Setup classes for removal
      @$(".title").removeClass("display").addClass "removal"
      @$(".menu_item").addClass "removal"
      
      # Bind removal animations
      @$(".title").css Utils.bp() + "animation-name", "raiseTitle"
      @$(".menu_item").css Utils.bp() + "animation-name", "raiseMenu"
      this

    
    # After removal animation, delete from DOM 
    cleanUp: (e) ->
      @$el.empty()  if @model.get("scene") isnt @sceneName and $(e.target).hasClass("title")
      false
  )
  
  # Scene for the game itself, displayed when "Play" is clicked 
  GameScene = Backbone.View.extend(
    className: "game_scene"
    events:
      animationend: "cleanUp"
      webkitAnimationEnd: "cleanUp"
      mozAnimationEnd: "cleanUp"

    scoreTemplate: _.template($("#_game_score").html())
    levelTemplate: _.template($("#_game_level").html())
    livesTemplate: _.template($("#_game_lives").html())
    sceneName: "game"
    initialize: ->
      _.bindAll this
      @eggViews = []
      @$el.on Utils.clickUpOrTouch(), ".back_button", @handleBackButton
      @model.on "change:scene", @renderSceneChange
      @model.get("eggCollection").on "add", @renderAddEgg
      @model.on "change:score", @renderScore
      @model.on "change:lives", @renderLives
      @model.on "change:level", @renderLevel
      @model.on "change:level", @renderLevelLabel

    handleBackButton: (e) ->
      @$(".back_button").addClass "disabled"
      @model.set "scene", "menu"

    renderSceneChange: (model, scene) ->
      if model.previous("scene") is @sceneName
        @renderRemoveScene()
      else @render()  if scene is @sceneName
      this

    render: ->
      self = this
      
      # Reset game data like score, lives, etc.
      @model.resetGameData()
      
      # Remove previous HUD
      @$("#hud").remove()
      @$el.append "<div id='hud'></div>"
      
      # Render templates
      @renderLevel()
      setTimeout (->
        self.renderLevelLabel()
      ), 1200
      @renderScore()
      @renderLives()
      @renderBackButton()
      @renderEggs()
      
      # Add to stage if necessary
      $("#stage").append @$el  if $("#stage ." + @className).length <= 0
      this

    renderLevel: ->
      if @$("#game_level").length > 0
        @$("#game_level").replaceWith @levelTemplate(level: @model.get("level"))
      else
        @$("#hud").append @levelTemplate(level: @model.get("level"))
      this

    renderLevelLabel: ->
      @$el.append "<p class='level_label'>LEVEL " + @model.get("level") + "<br>GET READY!</p>"
      setTimeout (->
        @$(".level_label").addClass "removal"
      ), 3000
      setTimeout (->
        @$(".level_label").remove()
      ), 3300
      this

    renderScore: ->
      if @$("#game_score").length > 0
        @$("#game_score").replaceWith @scoreTemplate(score: @model.get("score"))
      else
        @$("#hud").append @scoreTemplate(score: @model.get("score"))
      this

    renderLives: ->
      if @$("#game_lives").length > 0
        @$("#game_lives").replaceWith @livesTemplate(lives: @model.get("lives"))
      else
        @$("#hud").append @livesTemplate(lives: @model.get("lives"))
      this

    renderBackButton: ->
      if @$(".back_button").length > 0
        @$(".back_button").replaceWith "<div class='back_button'>X</div>"
      else
        @$el.append "<div class='back_button'>X</div>"
      this

    renderEggs: ->
      @model.addEggs()
      this

    renderAddEgg: (eggModel, collection, options) ->
      eggView = new EggView(
        model: eggModel
        gameState: @model
        scene: @$el
      )
      eggView.render()
      @eggViews.push eggView
      this

    renderRemoveScene: ->
      
      # Animate the HUD dissapearing
      @$(".back_button").css Utils.bp() + "animation-name", "xRaise"
      @$("#hud p").css Utils.bp() + "animation-name", "removeHUD"
      @$(".egg").css Utils.bp() + "transition-duration", "0.3s"
      
      # Remove all egg views and their models
      _.each @eggViews, (eggView) ->
        eggView.renderRemove()

      @model.get("eggCollection").reset()
      this

    
    # Do any remaining clean up after animations triggered
    #       in renderRemoveScene are completed. 
    cleanUp: (e) ->
      @$el.empty()  if @model.get("scene") isnt @sceneName and $(e.target).hasClass("back_button")
      false
  )
  
  # Scene displayed once the player loses the game 
  GameOverScene = Backbone.View.extend(
    className: "game_over_scene"
    events:
      animationend: "cleanUp"
      webkitAnimationEnd: "cleanUp"
      mozAnimationEnd: "cleanUp"

    template: _.template($("#_game_over").html())
    sceneName: "game_over"
    submitted: false
    initialize: ->
      _.bindAll this
      @model.on "change:scene", @renderSceneChange
      @$el.on Utils.clickUpOrTouch(), ".menu_button", @handleMenuButton
      @$el.on Utils.clickUpOrTouch(), ".replay_button", @handleReplayButton
      @$el.on Utils.clickUpOrTouch(), ".facebook_button", @handleFacebookButton

    handleMenuButton: (e) ->
      @$(".menu_item").addClass "disabled"
      @model.set "scene", "menu"

    handleReplayButton: (e) ->
      @$(".menu_item").addClass "disabled"
      @model.set "scene", "game"

    handleFacebookButton: (e) ->
      self = this
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
        Parse.FacebookUtils.logIn null,
          success: (user) ->
            
            # If it's a new user, let's fetch their name from FB
            unless user.existed()
              
              # We make a graph request
              FB.api "/me", (response) ->
                unless response.error
                  
                  # We save the data on the Parse user
                  user.set "displayName", response.name
                  user.save null,
                    success: (user) ->
                      
                      # And finally save the new score
                      self.saveHighScore()

                    error: (user, error) ->
                      console.log "Oops, something went wrong saving your name."

                else
                  console.log "Oops something went wrong with facebook."

            
            # If it's an existing user that was logged in, we save the score
            else
              self.saveHighScore()

          error: (user, error) ->
            console.log "Oops, something went wrong."


    
    # Create highscore object and save to Parse using Cloud Code 
    saveHighScore: ->
      self = this
      
      # Generate score hash (this makes it harder for hackers to 
      # submit an arbitrarily high value)
      submission = score: @model.getScoreSubmission()
      
      # Submit highscore using Cloud Code
      Parse.Cloud.run "submitHighscore", submission,
        success: (result) ->
          self.submitted = true
          self.$(".facebook_button").html "Submitted!"

        error: (error) ->
          self.submitted = true
          self.$(".facebook_button").html(" X Try Again...").removeClass "disabled"


    renderSceneChange: (model, scene) ->
      if model.previous("scene") is @sceneName
        @renderRemoveScene()
      else @render()  if scene is @sceneName
      this

    render: ->
      congratsIndex = (if @model.get("level") > GameOverScene.Congrats.length then GameOverScene.Congrats.length - 1 else @model.get("level") - 1)
      @$el.html @template(
        score: @model.get("score")
        congrats: GameOverScene.Congrats[congratsIndex]
      )
      $("#stage").append @$el

    renderRemoveScene: ->
      
      # Setup classes for removal
      @$(".menu_item").addClass "removal"
      @$(".summary").addClass "removal"
      
      # Bind removal animations
      @$(".menu_item").css Utils.bp() + "animation-name", "raiseMenu"
      @$(".summary").css Utils.bp() + "animation-name", "raiseScores"

    cleanUp: (e) ->
      @$el.empty()  if @model.get("scene") isnt @sceneName and $(e.target).hasClass("summary")
  ,
    Congrats: [
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
  )
  
  # Scene for the highscore, accessed from the menu button 
  HighscoreScene = Backbone.View.extend(
    className: "highscore_scene"
    events:
      animationend: "cleanUp"
      webkitAnimationEnd: "cleanUp"
      mozAnimationEnd: "cleanUp"

    template: _.template($("#_highscore").html())
    scoreTemplate: _.template($("#_score").html())
    sceneName: "highscore"
    initialize: ->
      _.bindAll this
      @model.on "change:scene", @renderSceneChange
      @model.get("highscoreCollection").on "reset", @renderScoreCollection
      @$el.on Utils.clickUpOrTouch(), ".back_button", @handleBackButton
      @render()  if @model.get("currentScene") is @sceneName

    handleBackButton: (e) ->
      @$(".back_button").addClass "disabled"
      @model.set "scene", "menu"
      false

    renderSceneChange: (model, scene) ->
      if model.previous("scene") is @sceneName
        @renderRemoveScene()
      else @render()  if scene is @sceneName
      this

    render: ->
      self = this
      
      # render view
      @$el.html @template()
      
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

    renderScoreCollection: ->
      self = this
      @model.get("highscoreCollection").each (score, index) ->
        self.renderScore score, index

      $(".highscore .spinner").remove()
      this

    renderScore: (score, index) ->
      @$("#score_table tbody").append @scoreTemplate(
        score: score
        index: index
      )

    renderRemoveScene: ->
      
      # Setup classes for removal
      @$(".menu_item").addClass "removal"
      @$(".highscore").addClass "removal"
      
      # Bind removal animations
      @$(".menu_item").css Utils.bp() + "animation-name", "raiseMenu"
      @$(".highscore").css Utils.bp() + "animation-name", "raiseScores"

    cleanUp: (e) ->
      @$el.empty()  if @model.get("scene") isnt @sceneName and $(e.target).hasClass("highscore")
  )
  
  # Scene for the credits, accessed from the menu button 
  CreditsScene = Backbone.View.extend(
    className: "credits_scene"
    template: _.template($("#_credits").html())
    sceneName: "credits"
    events:
      animationend: "cleanUp"
      webkitAnimationEnd: "cleanUp"
      mozAnimationEnd: "cleanUp"

    initialize: ->
      _.bindAll this
      @model.on "change:scene", @renderSceneChange
      @$el.on Utils.clickUpOrTouch(), ".back_button", @handleBackButton

    handleBackButton: (e) ->
      @$(".back_button").addClass "disabled"
      @model.set "scene", "menu"
      false

    renderSceneChange: (model, scene) ->
      if model.previous("scene") is @sceneName
        @renderRemoveScene()
      else @render()  if scene is @sceneName
      this

    render: ->
      self = this
      
      # render view
      @$el.html @template()
      
      # Add scene to the stage
      $("#stage").append @$el
      this

    renderRemoveScene: ->
      
      # Setup classes for removal
      @$(".credits").addClass "removal"
      @$(".back_button").addClass "removal"
      
      # Bind removal animations
      @$(".credits").css Utils.bp() + "animation-name", "raiseMenu"
      @$(".back_button").css Utils.bp() + "animation-name", "raiseMenu"

    cleanUp: (e) ->
      @$el.empty()  if @model.get("scene") isnt @sceneName and $(e.target).hasClass("credits")
  )
  
  # Let's go!
  Game.initialize()


# == Utils ==
# * Various utility functions used throughout
window.Utils =

# Generates the appropriate css browser prefix
  bp: ->
    bp = ""
    if $.browser.webkit
      bp = "-webkit-"
    else bp = "-moz-"  if $.browser.mozilla
    bp

  isSupported: ->
    not ($.browser.msie and parseInt($.browser.version) < 10)


# Executes the function on the next tick. This means
#   * it will run after the current execution flow is completed
  nextTick: (func) ->
    setTimeout func, 0


# Generates a touch or click up event name based on the device
  clickUpOrTouch: (func) ->
    (if "ontouchstart" of window then "touchstart" else "mouseup")


# Generates a touch or click down event name based on the device
  clickDownOrTouch: (func) ->
    (if "ontouchstart" of window then "touchstart" else "mousedown")


# Spin.js jQuery plugin
$.fn.spin = (opts) ->
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

#***********************************************************
# Be sure to add your Parse Keys and Facebook App ID Below!
#***********************************************************

# Initialize Parse
Parse.initialize "0ZUn1TaDF9G3j6UhvoNFuIVSzF45vpSO9K0rlosM", "oU1ToZ9LNZoMslphpgxQNoVjJXEqoi59M018ZP08"

# Initialize the Facebook SDK with Parse as described at
# https://parse.com/docs/js_guide#fbusers
window.fbAsyncInit = ->

  # init the FB JS SDK
  Parse.FacebookUtils.init
    appId: "1380103182250520" # Facebook App ID
    channelUrl: "/channel.html" # Channel File
    status: true # check login status
    cookie: true # enable cookies to allow Parse to access the session
    xfbml: true # parse XFBML


do (d = document, debug = false) ->
  js = undefined
  id = "facebook-jssdk"
  ref = d.getElementsByTagName("script")[0]
  return  if d.getElementById(id)
  js = d.createElement("script")
  js.id = id
  js.async = true
  js.src = "//connect.facebook.net/en_US/all" + ((if debug then "/debug" else "")) + ".js"
  ref.parentNode.insertBefore js, ref

