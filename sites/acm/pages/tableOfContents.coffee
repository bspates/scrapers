_ = require 'underscore'
article = require './article'

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
            links: []
          volume = $("p:contains('Volume')")
          res.volume = volume.text()
          abstracts = $(volume).siblings('table').find("a[href*='citation.cfm']").each (i, element) ->
            res.links.push element.getAttribute 'href'
          res
        , (result) ->
          if result 
            for link in result.links
              scraper.qlink link, article.callback
                
            callback()
          else 
            callback()
      , 2000
     