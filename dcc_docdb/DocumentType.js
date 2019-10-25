/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('DocumentType', {
    DocTypeID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    ShortType: {
      type: DataTypes.STRING(32),
      allowNull: true
    },
    LongType: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    NextDocNumber: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    }
  }, {
    tableName: 'DocumentType'
  })
}
