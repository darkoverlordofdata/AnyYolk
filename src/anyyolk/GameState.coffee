# == Game State =
#   * This model is transient and represents the state of the
#   * game. It is used to facilitate communication between the views,
#   * especially changing scenes and sharing game stats (score, 
#   * level, etc). 
anyyolk = require('../anyyolk')

class anyyolk.GameState extends Backbone.Model
  # The default game data used for a new game 
  @DefaultGameData =
    score     : 0
    lives     : 3
    level     : 1
    speedX    : 1

  defaults:
    scene           : ""
    eggCollection   : null
    speedX          : 1

  initialize: =>

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
  incrementScore: =>
    @set "score", @get("score") + 1


  # Decreases the user's lives by 1 
  decrementLife: =>
    @set "lives", @get("lives") - 1
    @validateAlive()


  # Increment the user's level by 1 and increases speed multiplier 
  incrementLevel: =>
    if @get("eggCollection").length <= 0
      @set "level", @get("level") + 1
      @set "speedX", @get("speedX") + 0.25
      @addEggs()


  # Checks if the user is still alive. If not, changes scene. 
  validateAlive: =>
    @set "scene", "game_over"  if @get("lives") <= 0


  # Add 10 eggs for the current level 
  addEggs: =>
    numEggs = 10
    i = 0

    while i < numEggs
      @get("eggCollection").add new anyyolk.EggModel(collectionIndex: i)
      i++


  # Remove broken or saved eggs from the model 
  cleanUpEgg: (eggModel) =>
    @get("eggCollection").remove eggModel


  # Resets the game's data (score, level, etc) for a new game 
  resetGameData: =>
    @set anyyolk.GameState.DefaultGameData


  # We hash the score before sending it to Cloud Code. This is an 
  #       efficient way to secure your highscore (though nothing is full proof) 
  getScoreSubmission: =>
    ((@get("level") * 362) << 5) + "." + ((@get("score") * 672) << 4)

