/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('DocumentTypeSecurity', {
    DocTypeSecID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    DocTypeID: {
      type: DataTypes.INTEGER(11),
      allowNull: false
    },
    GroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: false
    },
    IncludeType: {
      type: DataTypes.INTEGER(11),
      allowNull: true,
      defaultValue: '1'
    }
  }, {
    tableName: 'DocumentTypeSecurity'
  })
}
