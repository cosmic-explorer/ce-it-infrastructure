/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('RemoteUser', {
    RemoteUserID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    RemoteUserName: {
      type: DataTypes.CHAR(255),
      allowNull: false
    },
    EmailUserID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    },
    EmailAddress: {
      type: DataTypes.CHAR(255),
      allowNull: false
    }
  }, {
    tableName: 'RemoteUser'
  })
}
