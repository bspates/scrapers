archive = require './archive'

module.exports =

 callback: (err, page, scraper, callback) ->
    return callback(err) if err
    page.evaluate () ->
      $("a[title='Journal of the ACM (JACM)'][href!='http://jacm.acm.org/']").attr 'href'
    , (result) =>
      scraper.qlink result, archive.callback
      callback()