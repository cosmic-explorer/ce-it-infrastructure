/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('Journal', {
    JournalID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    Abbreviation: {
      type: DataTypes.STRING(64),
      allowNull: false,
      defaultValue: ''
    },
    Name: {
      type: DataTypes.STRING(128),
      allowNull: false,
      defaultValue: ''
    },
    Publisher: {
      type: DataTypes.STRING(64),
      allowNull: false,
      defaultValue: ''
    },
    URL: {
      type: DataTypes.STRING(240),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    Acronym: {
      type: DataTypes.STRING(8),
      allowNull: true
    }
  }, {
    tableName: 'Journal'
  });
};
