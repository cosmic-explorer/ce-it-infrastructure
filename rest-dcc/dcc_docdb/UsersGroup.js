/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('UsersGroup', {
    UsersGroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    EmailUserID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    GroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'UsersGroup'
  })
}
