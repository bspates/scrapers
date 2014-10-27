_ = require 'underscore'

tableOfContents = require './tableOfContents'

module.exports =
  callback: (err, page, scraper, callback) ->
    return callback(err) if err
    page.evaluate () ->
      window.clickEvent $("span:contains('Publication Archive')[unselectable!='on']").get(0)
      res = []
      $("a[href*='citation.cfm?']").each (i, element) ->
        res.push element.getAttribute 'href'
      return res
    , (result) ->
      _.each result, (link) ->
        scraper.qlink link, tableOfContents.callback
      callback()