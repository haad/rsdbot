# Description:
#   Bigger
#
#
# Configuration:
#   None
#
# Commands:
#   hubot show me bigger - gets Bigger daily menu
#
# Author:
#   mattonik


YQL = require "yql"

menuRequest = (msg) ->
  query = new YQL("SELECT * FROM data.html.cssselect WHERE url='http://bigger.sk/' AND css='#putac1 div'")
  query.exec (error, response) ->
    if response.query.results.results
      r = response.query.results.results.div
      rCount = r.length
      newResponse = '*Bigger Denné menu*\n'
      j = 0

      #console.log 'Response: ', r

      response = r[0].a.content
      response = response.replace(/(<([^>]+)>)/ig, "")
      response = response.replace(/\W+/, '')
      response = response.trim()
      response = response + '\n'
      newResponse += response

      response = r[2].content
      response = response.replace(/(<([^>]+)>)/ig, "")
      response = response.replace(/\W+/, '')
      response = response.trim()
      response = response + '\n'
      newResponse += response

      
      msg.send newResponse


module.exports = (robot) ->
  robot.respond /((show|fetch)( me )?)?bigger/i, (msg) ->
    menuRequest(msg)
