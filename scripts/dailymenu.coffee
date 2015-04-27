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

pages = [
  {
    title: 'Sit&Eat',
    url: 'http://restauracie.sme.sk/restauracia/siteat_4010-ruzinov_2980/denne-menu'
  },
  {
    title: 'Family Fine Food',
    url: 'http://restauracie.sme.sk/restauracia/family-fine-food_6787-ruzinov_2980/denne-menu'
  },
  {
    title: 'Presto',
    url: 'http://restauracie.sme.sk/restauracia/presto-bbc-i_2406-ruzinov_2980/denne-menu'
  }
]

menuRequest = (page, msg) ->
  query = new YQL("SELECT * FROM data.html.cssselect WHERE url='" + page.url + "' AND css='.denne_menu .dnesne_menu .jedlo_polozka'")
  query.exec (error, response) ->
    if response.query.results.results
      r = response.query.results.results.div
      rCount = r.length
      newResponse = '*' + page.title + '*\n'
      j = 0

      while j < rCount
        if r[j].div.b
          newResponse += '_' + r[j].div.b + '_\n'
        if r[j].div.content
          response = r[j].div.content
          response = response.replace(/(<([^>]+)>)/ig, "")
          response = response.replace(/\W+/, '')
          response = response.trim()
          response = response + '\n'
          response.substr(0, 2)
          newResponse += response
        j++
      msg.send newResponse

getDailyMenu = (pages, msg) ->
  numberOfPages = pages.length
  i = 0

  while i < numberOfPages
    menuRequest(pages[i], msg)
    i++

module.exports = (robot) ->
  robot.respond /((show|fetch)( me )?)?menu/i, (msg) ->
    getDailyMenu(pages, msg)
