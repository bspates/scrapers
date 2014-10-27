express = require 'express'
bodyParser = require 'body-parser'
path = require 'path'
mongoose = require 'mongoose'

BrowserScaper = require './utils/browserScraper'
Scrape = require './db/scrape'

mongoose.connect process.env.DATABASE_URL

app = express()
app.use bodyParser()


app.get '/', (req, res) ->
  res.json
    success: true
    results: {}
    message: 'stub endpoint' 

app.get '/scrape/:site', (req, res) ->
  phantom.create "--web-security=no", "--ignore-ssl-errors=yes", (ph) =>
    scraper = new BrowserScraper(ph)
    scraper.scrape req.param.site, (err, id) ->
      if err
        res.json
          success: false
          result: {}
          message: err
      else
        res.json
          success: true
          result: 
            id: id
          message: ''

app.get '/status/:id', (req, res) ->
  Scrape.findById req.param.id, 'status', (err, scrape) ->
    if err
      res.json
        success: false
        result: {}
        message: err
    else
      res.json
        success: true
        result: scrape
        message: ''

app.get '/results/:id', (req, res) ->
  Scrape.findById req.param.id, 'status pages', (err, scrape) ->
    if err
      res.json
        success: false
        result: {}
        message: err
    else
      res.json
        success: true
        result: scrape
        message: ''


app.listen process.env.PORT or 3000

console.log 'up and running'
