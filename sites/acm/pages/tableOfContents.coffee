abstract = require './abstract'
_ = require 'underscore'

module.exports = 
  callback: (err, page, scraper, callback) ->
    return callback(err) if err
    page.evaluate () ->
      window.clickEvent $("span:contains('Table of Contents')[unselectable!='on']").get(0)
    , (result) ->
      setTimeout () ->
        page.evaluate () ->
          res = []
          $("a[href*='citation.cfm?']").each (i, element) ->
            res.push element.getAttribute 'href'
          return res
        , (result) ->
          _.each result, (link) -> 
            scraper.qlink link, abstract.callback
          callback()
      , 1000
     