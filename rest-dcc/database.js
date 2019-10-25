const Sequelize = require('sequelize')
const epilogue = require('epilogue')
const path = require('path')

const database = new Sequelize('dcc_docdb', 'docdbrw', 'herecomethebadgers', {
  dialect: 'mariadb',
  host: 'localhost',
  operatorsAliases: false
})

const Docdb = database.import(path.join(__dirname, 'dcc_docdb/Author'))

const initializeDatabase = async (app) => {
  epilogue.initialize({ app, sequelize: database })

  epilogue.resource({
    model: Docdb,
    endpoints: ['/Author', '/Author/:AuthorID']
  })

  await database.sync()
}

module.exports = initializeDatabase
