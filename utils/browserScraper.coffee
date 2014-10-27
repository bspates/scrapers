phantom = require 'phantom'
async = require 'async'
_ = require 'underscore'
Scrape = require '../db/scrape'

module.exports = class BrowserScraper
  options: 
    concurrency: 1 #TODO allow queue to pipeline requests to different browser instances based on action dependency
    wait: 2000
  
  requestQ: null
  ph: null
  id: null

  constructor: (ph, options) ->
    if options
      @options = _.extend @options, options

    @ph = ph

    @requestQ = async.queue (task, callback) => 
      setTimeout () =>
        @ph.createPage (page) =>
          page.set 'onError', (msg, trace) ->
            console.log msg
          page.open task.url, (status) =>
            console.log task.url
            callback(status) if status isnt 'success'
            page.includeJs 'http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js', () =>
            @includeMethods page, () =>
              task.callback null, page, @, callback
      , @options.wait
    , @options.concurrency

    @requestQ.drain = () =>
      console.log 'queue empty phantom exiting'
      Scrape.update 
        _id: scraper.id
      , $set:
          status: 'complete'
      , (err, result) ->
        console.log err

      @ph.exit()

  scrape: (site, callback) ->
    home = require '../sites/' + site + '/pages/home'

    scrape = new Scrape
      siteName: site

    scrape.save (err, result) =>
      return callback(err) if err
      @requestQ.push home
      @id = result._id
      callback null, result._id


  includeMethods: (page, callback) ->
    page.evaluate () ->
      window.clickEvent = (el) ->
        ev = document.createEvent 'MouseEvent'
        ev.initMouseEvent 'click', true, true, window, null, 0, 0, 0, 0, false, false, false, false, 0, null
        el.dispatchEvent(ev)
          
    , callback

  handle: (err, callback) =>
    if callback
      if typeof(callback) isnt 'function'
        throw 'invalid type sent as callback: ' + callback
      if err
        callback(err)
        @requestQ.kill()
      else
        callback()
    else
      throw err if err

  qlink: (href, callback) =>
    return callback('href undefined') unless href

    if href.indexOf('http') < 0
      url = 'http://dl.acm.org/' + href
    else
      return callback 'wrong url type'

    @requestQ.push
      url: url
      callback: callback
    , @handle