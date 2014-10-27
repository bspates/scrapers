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
    results: String
  ]

module.exports = mongoose.model 'Site', SiteSchema