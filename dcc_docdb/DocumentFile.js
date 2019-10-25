/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('DocumentFile', {
    DocFileID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    DocRevID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    },
    FileName: {
      type: DataTypes.STRING(255),
      allowNull: false,
      defaultValue: ''
    },
    Date: {
      type: DataTypes.DATE,
      allowNull: true
    },
    RootFile: {
      type: DataTypes.INTEGER(4),
      allowNull: true,
      defaultValue: '1'
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    Description: {
      type: DataTypes.STRING(128),
      allowNull: true
    }
  }, {
    tableName: 'DocumentFile'
  });
};
