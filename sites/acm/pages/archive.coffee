_ = require 'underscore'

tableOfContents = require './tableOfContents'

module.exports =
  callback: (err, page, scraper, callback) ->
    return callback(err) if err
    page.evaluate () ->
      window.clickEvent $("span:contains('Publication Archive')[unselectable!='on']").get(0)
      return $("a[href*='citation.cfm']")
    , (result) ->
      console.log result.length
      # _.each result, (link) ->
      #   scraper.qlink link, tableOfContents.callback
      callback()