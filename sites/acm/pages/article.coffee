_ = require 'underscore'
Scrape = require '../../../db/scrape.coffee'

module.exports =
  callback: (err, page, scraper, callback) ->
    return callback(err) if err
    page.evaluate () ->
      if $("span:contains('Abstract')").parent().parent().hasClass("on")
        return 'Abstract'
      else if $("span:contains('Search Terms')").parent().parent().hasClass("on")
        return 'Index Terms'
      else 
        return 'error'
      
    , (res) ->
      categories =  () ->
        results = []
        $("a[class*='boxed']").parent().each (i, element) ->
          results.push 
            category: element.textContent
            weight: element.getAttribute 'style'
        {categories: results}

      abstract = () ->
        {abstract: $("div#abstract").text(), title: $("#divmain").find("h1").text()}

      runOne = null
      runTwo = null
      changeTab = null
      switch res
        when 'Abstract'
          runOne = abstract
          runTwo = categories
          changeTab = -> window.clickEvent $("span:contains('Index Terms')[unselectable!='on']").get(0)
        when 'Index Terms'
          runOne = categories
          runTwo = abstract
          changeTab = -> window.clickEvent $("span:contains('Abstract')[unselectable!='on']").get(0)
        when 'error'
          console.log 'page has no abstract or index terms'
          return callback()
        else 
          return callback 'no page'

      page.evaluate runOne, (resOne) ->
        page.evaluate changeTab, () ->
          setTimeout () ->
            page.evaluate runTwo, (resTwo) ->
              results = _.extend resOne, resTwo
              return callback() unless results.abstract
              Scrape.update 
                  _id: scraper.id
                , 
                  $push:
                    pages:
                      name: 'article: ' + results.title
                      results:
                        abstracts: results.abstract
                        categories: results.categories
                , (err) ->
                  callback err
          , 2000

