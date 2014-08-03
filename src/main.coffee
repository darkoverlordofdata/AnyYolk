#***********************************************************
# Be sure to add your Parse Keys and Facebook App ID Below!
#***********************************************************



# Initialize Parse Keys
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


$ -> # Document::ready
  
  # == Entry Point ==
  #   * This is the main entry point to the game, it
  #   * initialializes all necessary elements to run the game 
  #  Game = initialize: ->
  anyyolk = require('./anyyolk')
  if anyyolk.isSupported()


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
    $("#stage").on "dragstart selectstart", "*", (event) ->
      false


    # disable scrolling on smartphones
    document.ontouchmove = (e) ->
      e.preventDefault()
  else
    $("#unsupported").show()

  
