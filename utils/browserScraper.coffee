phantom = require 'phantom'
async = require 'async'
_ = require 'underscore'

module.exports = class Scraper
  defaultOptions: 
    concurrency: 1
    wait: 2000
  
  requestQ: null
  ph: null
  requestQ: null

  constructor: (ph, id, options) ->
    if options
      @options = _.extend @defaultOptions, options

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
            @includeMethods page () ->
              task.callback null, page, @, callback
      , @options.wait
    , @options.concurrency

    @requestQ.drain = () =>
      console.log 'queue empty phantom exiting'
      @ph.exit()

  scrapeSite: (site, output) ->
    home = require './sites/' + site + '/home'
    @requestQ.push home

  includeMethods: (page, callback) ->
    page.evaluate () ->
      window.clickEvent = (el) ->
        ev = document.createEvent 'MouseEvent'
        ev.initMouseEvent 'click', true, true, window, null, 0, 0, 0, 0, false, false, false, false, 0, null
        el.dispatchEvent(ev)
          
    , callback

  handle: (err, callback) =>
    if callback
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