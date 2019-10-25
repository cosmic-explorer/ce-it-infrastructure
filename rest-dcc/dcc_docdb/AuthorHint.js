/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('AuthorHint', {
    AuthorHintID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    SessionTalkID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    AuthorID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'AuthorHint'
  })
}
