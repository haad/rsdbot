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
moment = require "moment"
request = require "request"

zomatoKey = '4e1f6f82254556bb2b8250017433edfb'

zomato = [
  {
    title: 'La Strada Ristorante',
    id: 18014010
  }
]

pages = [
  {
    title: 'Sit&Eat',
    url: 'http://www.restaurantpresto.sk/sk/menu/sit-and-eat/',
    customYql: "SELECT * FROM data.html.cssselect WHERE url='http://www.restaurantpresto.sk/sk/menu/sit-and-eat/' AND css='.list li h3'",
    resultsContainer: 'h3',
    responseHandler: ( r ) ->
      j = 0
      response = ''
      rCount = r.length
      
      while j < rCount
        response += '• ' + r[j].content.trim() + '\n'
        j++
      return response
  },
  {
    title: 'Presto BBC I',
    url: 'http://www.restaurantpresto.sk/sk/menu/presto-bbc-i/',
    customYql: "SELECT * FROM data.html.cssselect WHERE url='http://www.restaurantpresto.sk/sk/menu/presto-bbc-i/' AND css='.list li h3'",
    resultsContainer: 'h3',
    responseHandler: ( r ) ->
      j = 0
      response = ''
      rCount = r.length
      
      while j < rCount
        response += '• ' + r[j].content.trim() + '\n'
        j++
      return response
  },
  {
    title: 'Lunch Break',
    url: 'http://www.lunch-break.sk/menu/',
    customYql: "SELECT * FROM data.html.cssselect WHERE url='http://www.lunch-break.sk/menu/' AND css='#page-content table tbody tr'",
    resultsContainer: 'tr',
    responseHandler: ( r ) ->
      today = moment().day()
      days = ['Pondelok', 'Utorok', 'Streda', 'Štvrtok', 'Piatok']
      fullResponse = ''
      rCount = r.length
      j = 0
      k = 0
      index = 0

      while j < rCount
        if ( r[j]['td'][0] == days[today - 1] )
          p = r[j]['td']
          index = j
          response = '• ' + p[1] + ': ' + p[3] + ' (' + p[2] + ')\n'
          fullResponse += response
        j++

      while k < 3
        p = r[index + (k + 1)]['td']
        response = '• ' + p[1] + ': ' + p[3] + ' (' + p[2] + ')\n'
        fullResponse += response
        k++ 
      
      return fullResponse
  },
  # {
  #   title: 'Family Fine Food',
  #   url: 'http://restauracie.sme.sk/restauracia/family-fine-food_6787-ruzinov_2980/denne-menu'
  # },
  {
      title: 'Buddies',
      url: 'http://restauracie.sme.sk/restauracia/buddies_7319-ruzinov_2980/denne-menu'
  },
  {
    title: 'Top Gastro Gurmán (Time Machine)',
    url: 'http://restauracie.sme.sk/restauracia/top-gastro-gurman_3291-ruzinov_2980/denne-menu'
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

          if r[j].span? && r[j].span.b?
            response = response + ' (' + r[j].span.b + ')'

          response = response + '\n'
          response.substr(0, 2)
          response = '• ' + response
          newResponse += response
        j++
    else
      newResponse = '*' + page.title + '*\n' + '_Menu nie je dostupné_\n'
    msg.send newResponse
    #return newReponse

customMenuRequest = (page, msg) ->
  query = new YQL(page.customYql)
  query.exec (error, response) ->
    if response.query.results.results
      r = response.query.results.results[ page.resultsContainer ]
      newResponse = '*' + page.title + '*\n'
      newResponse += page.responseHandler( r )
    else
      newResponse = '*' + page.title + '*\n' + '_Menu nie je dostupné_\n'
    msg.send newResponse
    
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

getBigger = (msg) ->
  query = new YQL("SELECT * FROM data.html.cssselect WHERE url='http://bigger.sk/' AND css='#putac1 div'")
  query.exec (error, response) ->
    if response.query.results.results
      r = response.query.results.results.div
      rCount = r.length
      newResponse = '*Bigger Denné menu*\n'
      j = 0

      response = r[0].a.content
      response = response.replace(/(<([^>]+)>)/ig, "")
      response = response.replace(/\W+/, '')
      response = response.trim()
      response = response + '\n'
      newResponse += '• ' + response

      response = r[2].content
      response = response.replace(/(<([^>]+)>)/ig, "")
      response = response.replace(/\W+/, '')
      response = response.trim()
      response = response + '\n'
      newResponse += '• ' + response

      msg.send newResponse

getDailyMenu = (pages, zomato, msg) ->
  day = moment().format('DD.MM.YYYY')
  msg.send "Hľadám denné menu na " + day
  numberOfPages = pages.length
  dailyMenus = []
  i = 0
  
  getBigger(msg)

  while i < numberOfPages
    if pages[i].customYql
      customMenuRequest(pages[i], msg)
    else
      menuRequest(pages[i], msg)
    i++
    
  numberOfZomato = zomato.length
  i = 0
  while i < numberOfZomato
    zomatoMenu( zomato[i], msg )
    i++

module.exports = (robot) ->
  robot.respond /((show|fetch)( me )?)?menu/i, (msg) ->
    getDailyMenu(pages, zomato, msg)
