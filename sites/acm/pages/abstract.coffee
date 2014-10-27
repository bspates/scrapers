Scrape = require '../../../db/scrape.coffee'

module.exports =
  callback: (err, page, scraper, callback) ->
    page.evaluate () ->
      if $("td.on").text() is 'Abstract'
        return $.trim $("div.x-tabs-body").text()
      else 
        return null
    , (result) ->
      if result
        Scrape.update 
          _id: scraper.id
        , 
          $push:
            pages:
              name: 'abstract'
              results: result
        , callback
      else 
        callback()