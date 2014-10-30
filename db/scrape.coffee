mongoose = require 'mongoose'
Schema = mongoose.Schema

ScrapeSchema = new Schema
  siteName: String
  status: 
    type: String
    default: 'in progress'
  pages: [
    name: String
    date: 
      type: Date
      default: Date.now
    results: Schema.Types.Mixed
  ]

module.exports = mongoose.model 'Scrape', ScrapeSchema