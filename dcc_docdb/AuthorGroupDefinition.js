/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('AuthorGroupDefinition', {
    AuthorGroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    AuthorGroupName: {
      type: DataTypes.STRING(32),
      allowNull: false
    },
    Description: {
      type: DataTypes.STRING(64),
      allowNull: true
    }
  }, {
    tableName: 'AuthorGroupDefinition'
  })
}
