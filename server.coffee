express = require 'express'
bodyParser = require 'body-parser'
path = require 'path'
shortId = require 'shortid'

BrowserScaper = require './utils/browserScraper'


app = express()
app.use bodyParser()

app.get '/scrape/acm', (req, res) ->
  id = shortId.generate()
  phantom.create "--web-security=no", "--ignore-ssl-errors=yes", (ph) =>
    scraper = new BrowserScraper(ph, id)
    scraper.scrape 'acm'
    res.json
      success: true
      result: 
        id: id

app.get '/status/:id', (req, res) ->


app.listen process.env.PORT or 3000

console.log 'up and running'
