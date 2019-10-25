/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('Signoff', {
    SignoffID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    DocRevID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    Note: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'Signoff'
  });
};