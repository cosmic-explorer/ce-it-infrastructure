/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('RevisionAuthorGroup', {
    RevAuthorGroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    AuthorGroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: false
    },
    DocRevID: {
      type: DataTypes.INTEGER(11),
      allowNull: false
    }
  }, {
    tableName: 'RevisionAuthorGroup'
  })
}
