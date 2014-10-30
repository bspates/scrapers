Scrape = require '../../../db/scrape.coffee'

module.exports =
  callback: (err, page, scraper, callback) ->
    page.evaluate () ->
      res = 
        dom: null
        results: null
      if $("td.on").text() is 'Abstract'
        res.results = $.trim $("div.x-tabs-body div#abstract par").text()
      else 
        res.dom = $('body').text()
      res
    , (result) ->
      if result
        Scrape.update 
          _id: scraper.id
        , 
          $push:
            pages:
              name: 'abstract'
              results: result.results
              dom: result.dom
        , (err) ->
          callback err
      else 
        console.log 'nope'
        callback()