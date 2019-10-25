/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('KeywordGrouping', {
    KeywordGroupingID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    KeywordGroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    KeywordID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'KeywordGrouping'
  })
}
