_ = require 'underscore'
module.exports =
  callback: (err, page, scraper, callback) ->
    return callback(err) if err
    console.log 'article'
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
          changeTab = 'Index Terms'
        when 'Index Terms'
          runOne = categories
          runTwo = abstract
          changeTab = 'Abstract'
        when 'error'
          return callback 'bad page'
        else 
          return callback 'no page'

      page.evaluate runOne, (resOne) ->
        page.evaluate () ->
          window.clickEvent $("span:contains('#{changeTab}')[unselectable!='on']").get(0)
        , () ->
          setTimeout () ->
            page.evaluate runTwo, (resTwo) ->
              results = _.merge resOne, resTwo
              return callback() unless results.abstract
              console.log 'saving result for ' + results.title
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

