abstract = () ->
  {abstract: $("div#abstract").text(), title: $("#divmain").find("h1").text()}

categories = () ->
  results = []
  $("a[class*='boxed']").parent().each (i, element) ->
    results.push 
      category: element.textContent
      weight: element.getAttribute 'style'
  {categories: results}

whichTab = (title) ->
  $("span:contains('#{title}')").parent().parent().hasClass("on")

module.exports = 
  callback: (err, page, scraper, callback) ->
    return callback(err) if err
    page.evaluate () ->
      if whichTab 'Abstract'
        return 'Abstract'
      else if whichTab 'Index Terms'
        return 'Index Terms'
      else 
        return 'error'
      
    , (res) ->
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
          callback 'bad page'
      page.evaluate runOne, (resOne) ->
        page.evaluate () ->
          window.clickEvent $("span:contains('#{changeTab}')[unselectable!='on']").get(0)
        , () ->
          setTimeout () ->
            page.evaluate runTwo, (resTwo) ->
              results = _.merge resOne, resTwo
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

