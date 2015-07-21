# Description:
#   Adds rating for burgers
# 
# Dependencies:
#
# Configuration:
#
# Commands:
#   hubot burger rate <name> <rating> - Rate burger on scale 0-10
#   hubot burger show - Show ratings of burgers
#   hubot burger reset - Reset ratings
#
# Author:
#   kuboj

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

String::repeat = (n) -> Array(n+1).join(this)

class Burgers
  constructor: (@robot) ->
    @ratings = {}
    @robot.brain.on 'loaded', =>
      if @robot.brain.data.burger_ratings
        @ratings = @robot.brain.data.burger_ratings

  ratings: -> @ratings

  reviewers: -> [].concat((Object.keys(r) for p, r of @ratings)...).unique()

  places: -> (p for p, r of @ratings).unique()

  rate: (reviewer, place, rating, res) ->
    if place.length > 0 and rating >= 0 and rating <= 10

      if place not in this.places()
        @ratings[place] = {}
        for r in this.reviewers()
          @ratings[place][r] = "-"

      if reviewer not in this.reviewers()
        for p in this.places()
          @ratings[p][reviewer] = "-"

      @ratings[place][reviewer] = rating

      @robot.brain.data.burger_ratings = @ratings
      if rating < 4 # 0-3
        res.send("#{rating}? I wouldn't feed me dog with that!")
      else if rating < 6 # 4-5
        res.send("Isn't even McDonalds better than that?")
      else if rating < 8 # 6-7
        res.send("Not that bad. I'm starting to feel hungry now I guess...")
      else if rating < 10 # 8-9
        res.send("Oh! Bring me some of that!")
      else # 10
        res.send("Praise the king of burgers!")
    else
      res.send("Sorry, I don't understand the format of this rating. Consult 'burger help'.")

  show: (res) ->
    output = {}
    reviewers = this.reviewers()
    places = this.places()
    p_max_length = -1
    r_max_length = -1

    for p in places
      p_max_length = Math.max(p_max_length, p.length)

    for r in reviewers
      r_max_length = Math.max(r_max_length, r.length)

    s = "```\n#{' '.repeat(p_max_length + 1)}"

    for r in reviewers
      s += "#{r}#{' '.repeat(r_max_length - r.length + 1)}"

    for p in places
      s += "\n#{p}#{' '.repeat(p_max_length - p.length + 1)}"
      for r in reviewers
        @ratings[p][r] = "-" unless @ratings[p][r]?
        s += "#{@ratings[p][r]}#{' '.repeat(r_max_length - 1)}"
        if @ratings[p][r] != 10
          s += " "

    s += "\n```"

    res.send(s)
    
  reset: ->
    @ratings = {}
    @robot.brain.data.burger_ratings = @ratings

module.exports = (robot) ->
  burgers = new Burgers robot
  
  robot.respond /burger rate (.+) ([0-9]|10)$/i, (res) ->
    reviewer = res.message.user.name
    place = res.match[1]
    rating = res.match[2]
    burgers.rate(reviewer, place, rating, res)

  robot.respond /burger show$/, (res) ->
    burgers.show(res)
  
  robot.respond /burger reset$/, (res) ->
    burgers.reset()
    res.send("Burger ratings cleared")
