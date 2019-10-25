/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('ExternalDocDB', {
    ExternalDocDBID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    Project: {
      type: DataTypes.STRING(32),
      allowNull: true
    },
    Description: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    PublicURL: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    PrivateURL: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'ExternalDocDB'
  });
};
