fs = require 'fs'

module.exports =
  callback: (err, page, scraper, callback) ->
    page.evaluate () ->
      if $("td.on").text() is 'Abstract'
        return $.trim $("div.x-tabs-body").text()
      else 
        return null
    , (result) ->
      if result
        fs.appendFile 'results.txt', result.join('\n\n'), callback
      else 
        callback()