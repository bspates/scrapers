journal = require './journal'

module.exports =  
  url: 'http://dl.acm.org'
  callback: (err, page, scraper, callback) =>
    return callback(err) if err
    page.evaluate () -> 
      return $("a[href*='pubs.cfm?']").attr 'href'
    , (result) =>
      scraper.qlink result, journal.callback
      callback()