express = require 'express'
bodyParser = require 'body-parser'
path = require 'path'
mongoose = require 'mongoose'
phantom = require 'phantom'

BrowserScraper = require './utils/browserScraper'
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
  scraper = new BrowserScraper()
  scraper.scrape req.params.site, (err, id) ->
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
  Scrape.findById req.params.id, 'status', (err, scrape) ->
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
  Scrape.findById req.params.id, 'status pages', (err, scrape) ->
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
