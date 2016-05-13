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

moment = require "moment"
request = require "request"
parser = require "jq-html-parser"

zomatoKey = '4e1f6f82254556bb2b8250017433edfb'

zomato = [
  {
    title: 'Buddies',
    id: 17740573
  },
  {
    title: 'La Strada Ristorante',
    id: 18014010
  },
  {
    title: 'Solo Sole',
    id: 16508221
  },
  {
    title: 'Sit & Eat',
    id: 16507676
  },
  {
    title: 'Presto BBC I.',
    id: 16507666
  },
  {
    title: 'Moose Pub',
    id: 17805642
  }
]

pages = [
  {
    title: 'Lunch Break',
    url: 'http://www.lunch-break.sk/menu/',
    config: {
      table: {
        selector: '#page-content .pro_table:first tbody tr',
        multiple: true
        # html: true
      }
    },
    parser: ( result, config, newResponse ) ->
      today = moment().day() - 1
      rowsPerDay = 4
      rowStart = today * rowsPerDay
      i = rowStart
      
      # console.log('lunch', today, rowStart, rowsPerDay, result.table, result.table.length)
      
      while i < ( rowStart + rowsPerDay )
        # console.log('row', i, result.table[i])
        newResponse += '• ' + result.table[i] + '\n'
        i++
      
      # console.log('Lunch Break', newResponse)
      return newResponse
  },
  {
    title: 'Bigger',
    url: 'http://bigger.sk/',
    config: {
      title: {
        selector: '#putac1 .tovarlink-small'
      },
      desc: {
        selector: '#putac1 .dm-popis'
      }
    },
    parser: ( result, config, newResponse ) ->
      for k, v of config
        # console.log('res', k, result[k] )
        newResponse += '• ' + result[k] + '\n'
      return newResponse
  }
]

parserMenu = (page, msg) ->
  parserCallback = (error, response, body) ->
    if ( error || response.statusCode != 200 )
      return console.log("An error occured.");
    
    newResponse = '*' + page.title + '*\n'
    
    myParser = new parser( page.config )
    result = myParser.parse( body )
    newResponse = page.parser( result, page.config, newResponse )
      
    msg.send newResponse
      
  request.get( page.url, parserCallback )

    
zomatoMenu = (zom, msg) ->
  options = {
    url: 'https://developers.zomato.com/api/v2.1/dailymenu?res_id=' + zom.id,
    json: true,
    headers: {
      'user_key': zomatoKey
    }
  }
  
  zomCallback = (error, response, body) ->
    if (!error && response.statusCode == 200)
      # console.log('zomato', zom.title, body)
      newResponse = '*' + zom.title + '*\n'
      
      r = body.daily_menus[0].daily_menu.dishes
      # console.log('r', r, r.length)
      rCount = r.length
      i = 0
      while i < rCount
        dish = r[i].dish.name.trim()
        newResponse += '• ' + dish + ': ' + r[i].dish.price + '\n'
        i++
        
      msg.send newResponse
  
  request( options, zomCallback )

getDailyMenu = (pages, zomato, msg) ->
  day = moment().format('DD.MM.YYYY')
  msg.send "Hľadám denné menu na " + day
  numberOfPages = pages.length
  dailyMenus = []
  i = 0
  
  # getBigger(msg)

  # while i < numberOfPages
  #   if pages[i].customYql
  #     customMenuRequest(pages[i], msg)
  #   else
  #     menuRequest(pages[i], msg)
  #   i++
    
  numberOfZomato = zomato.length
  i = 0
  while i < numberOfZomato
    zomatoMenu( zomato[i], msg )
    i++
    
  for v in pages
    parserMenu( v, msg )

module.exports = (robot) ->
  robot.respond /((show|fetch)( me )?)?menu/i, (msg) ->
    getDailyMenu(pages, zomato, msg)
