/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('Session', {
    SessionID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    ConferenceID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    StartTime: {
      type: DataTypes.DATE,
      allowNull: true
    },
    Title: {
      type: DataTypes.STRING(128),
      allowNull: true
    },
    Description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    Location: {
      type: DataTypes.STRING(128),
      allowNull: true
    },
    AltLocation: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    ShowAllTalks: {
      type: DataTypes.INTEGER(11),
      allowNull: true,
      defaultValue: '0'
    }
  }, {
    tableName: 'Session'
  });
};
