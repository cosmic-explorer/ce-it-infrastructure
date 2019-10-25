/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('AuthorGroupList', {
    AuthorGroupListID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    AuthorGroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: false
    },
    AuthorID: {
      type: DataTypes.INTEGER(11),
      allowNull: false
    }
  }, {
    tableName: 'AuthorGroupList'
  })
}
