/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('RevisionModify', {
    RevModifyID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    GroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    DocRevID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'RevisionModify'
  })
}
