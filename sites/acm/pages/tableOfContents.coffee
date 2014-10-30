_ = require 'underscore'

Scrape = require '../../../db/scrape.coffee'

module.exports = 
  callback: (err, page, scraper, callback) ->
    return callback(err) if err
    page.evaluate () ->
      window.clickEvent $("span:contains('Table of Contents')[unselectable!='on']").get(0)
    , (result) ->
      setTimeout () ->
        page.evaluate () ->
          res =
            volume: null
            abstracts: null
            count: null
          volume = $("p:contains('Volume')")
          res.volume = volume.text()
          abstracts = $(volume).siblings('table').find('p, par')
          if abstracts.length is 0 
            abstracts = $(volume).siblings('table').find("span[id*='toHide']")
          res.count = abstracts.length
          res.abstracts = abstracts.text()
          res
        , (result) ->
          if result
            Scrape.update 
              _id: scraper.id
            , 
              $push:
                pages:
                  name: 'table of contents of: ' + result.volume
                  results:
                    abstracts: result.abstracts
                    count: result.count
            , (err) ->
              callback err
          else 
            callback()
      , 2000
     