# Description:
#   Denne menu
#
#
# Configuration:
#   None
#
# Commands:
#   hubot show me menu - gets the daily menu
#
# Author:
#   mattonik


YQL = require "yql"
sitEatUrl = 'http://restauracie.sme.sk/restauracia/siteat_4010-ruzinov_2980/denne-menu'
fffUrl = 'http://restauracie.sme.sk/restauracia/family-fine-food_6787-ruzinov_2980/denne-menu'
sitEatQuery = new YQL('SELECT * FROM data.html.cssselect WHERE url=\'' + sitEatUrl + '\' AND css=\'.denne_menu .dnesne_menu .jedlo_polozka\'')
fffQuery = new YQL('SELECT * FROM data.html.cssselect WHERE url=\'' + fffUrl + '\' AND css=\'.jedlo_polozka\'')

getDailyMenu = (query, msg, restaurant) ->
  query.exec (error, response) ->
    r = response.query.results.results.div
    rCount = r.length
    newResponse = '*' + restaurant + '*\n'
    i = 0
    while i < rCount
      if r[i].div.b
        newResponse += '*' + r[i].div.b + '*\n'
      if r[i].div.content
        response = r[i].div.content
        response = response.replace(/(<([^>]+)>)/ig, "")
        response = response.replace(/\W+/, '')
        #response = response.replace('\n', '')
        response = response.trim()
        response = response + '\n'
        response.substr(0, 2)
        newResponse += response
      i++
    msg.send newResponse

module.exports = (robot) ->
  robot.respond /((show|fetch)( me )?)?menu/i, (msg) ->
    getDailyMenu(fffQuery, msg, 'Family Fine Food')
    getDailyMenu(sitEatQuery, msg, 'Sit&Eat')