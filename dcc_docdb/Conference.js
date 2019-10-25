/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('Conference', {
    ConferenceID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    Location: {
      type: DataTypes.STRING(64),
      allowNull: false,
      defaultValue: ''
    },
    URL: {
      type: DataTypes.STRING(240),
      allowNull: true
    },
    StartDate: {
      type: DataTypes.DATEONLY,
      allowNull: true
    },
    EndDate: {
      type: DataTypes.DATEONLY,
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    Title: {
      type: DataTypes.STRING(128),
      allowNull: true
    },
    Preamble: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    Epilogue: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    ShowAllTalks: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    EventGroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    LongDescription: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    AltLocation: {
      type: DataTypes.STRING(255),
      allowNull: true
    }
  }, {
    tableName: 'Conference'
  })
}
