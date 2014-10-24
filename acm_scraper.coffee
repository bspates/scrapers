async = require 'async'
# request = require 'request'
# cheerio = require 'cheerio'
phantom = require 'phantom'
_ = require 'underscore'
fs = require 'fs'

class AcmScraper

  concurrency: 1
  requestQ: null
  wait: 1000
  ph: null

  handle: (err, callback) =>
    if callback
      if err
        callback(err)
        @ph.exit()
        @requestQ.kill()
      else
        callback()
    else
      throw err if err

  constructor: (ph) ->
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
              page.evaluate () ->
                window.clickEvent = (el) ->
                  ev = document.createEvent 'MouseEvent'
                  ev.initMouseEvent 'click', true, true, window, null, 0, 0, 0, 0, false, false, false, false, 0, null
                  el.dispatchEvent(ev)
              , () =>
                task.callback null, page, callback
      , @wait
    , @concurrency

    @requestQ.drain = () =>
      console.log 'empty'
      @ph.exit()

  home: =>
    @requestQ.push 
      url: 'http://dl.acm.org'
      callback: (err, page, callback) =>
        return callback(err) if err
        page.evaluate () -> 
          return $("a[href*='pubs.cfm?']").attr 'href'
        , (result) =>
          @qlink result, @journal
          callback()
    , @handle


  journal: (err, page, callback) =>
    return callback(err) if err
    page.evaluate () ->
      $("a[title='Journal of the ACM (JACM)'][href!='http://jacm.acm.org/']").attr 'href'
    , (result) =>
      @qlink result, @archive
      callback()

  archive: (err, page, callback) =>
    return callback(err) if err
    page.evaluate () ->
      window.clickEvent $("span:contains('Publication Archive')[unselectable!='on']").get(0)
      res = []
      $("a[href*='citation.cfm?']").each (i, element) ->
        res.push element.getAttribute 'href'
      return res
    , (result) =>
      _.each result, (link) =>
        @qlink link, @tableOfContents
      callback()

  tableOfContents: (err, page, callback) =>
    return callback(err) if err
    page.evaluate () ->
      window.clickEvent $("span:contains('Table of Contents')[unselectable!='on']").get(0)
      res = []
      $("a[href*='citation.cfm?']").each (i, element) ->
        window.clickEvent element
        if $("td.on").text() is 'Abstract'
          res.push $.trim $("div.x-tabs-body").text()
      return res
    , (result) =>
      if result
        fs.appendFile 'results.txt', result.join('\n\n'), callback
      else 
        callback()

  # extractAbstract: (err, page, callback) =>
  #   return callback(err) if err
  #   page.evaluate () ->
     
  #   , (result) =>
  #     if result
  #       fs.appendFile 'results.txt', result + '\n\n', callback
  #     else
  #       callback()

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


phantom.create "--web-security=no", "--ignore-ssl-errors=yes", (ph) =>
  s = new AcmScraper ph
  s.home()



# untab = $('a').filter (index) ->
#   return $(@).text() is 'single page view'

# if untab[0]
#   window.clickEvent untab.get(0)