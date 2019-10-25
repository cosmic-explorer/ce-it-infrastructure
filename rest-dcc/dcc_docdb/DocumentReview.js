/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('DocumentReview', {
    DocReviewID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    DocumentID: {
      type: DataTypes.INTEGER(11),
      allowNull: false
    },
    VersionNumber: {
      type: DataTypes.INTEGER(11),
      allowNull: false
    },
    ReviewState: {
      type: DataTypes.INTEGER(4),
      allowNull: false,
      defaultValue: '0'
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    Obsolete: {
      type: DataTypes.INTEGER(4),
      allowNull: true,
      defaultValue: '0'
    },
    EmployeeNumber: {
      type: DataTypes.INTEGER(11),
      allowNull: false
    }
  }, {
    tableName: 'DocumentReview'
  })
}
