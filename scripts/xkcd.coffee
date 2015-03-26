# Description:
#   xkcd
#
# Dependencies:
#   "htmlparser": "1.7.6"
#
# Configuration:
#   None
#
# Commands:
#   hubot show me xkcd - gets the daily xkcd
#
# Author:
#   evilmarty

htmlparser = require "htmlparser"

module.exports = (robot) ->
  robot.respond /((show|fetch)( me )?)?xkcd/i, (msg) ->
    xkcdRss msg, (url) ->
      msg.send url

xkcdRegexp = /src=&quot;(.*.png)/i
xkcdRss = (msg, cb) ->
  msg.http('http://pipes.yahoo.com/pipes/pipe.run?_id=f6dc4fb85ab6642893968c963314b29d&_render=rss')
    .get() (err, resp, body) ->
      handler = new htmlparser.RssHandler (error, dom) ->
        return if error || !dom
        item = dom.items[0]
        match = item.description.match(xkcdRegexp)
        cb match[1] if match

      parser = new htmlparser.Parser(handler)
      parser.parseComplete(body)
