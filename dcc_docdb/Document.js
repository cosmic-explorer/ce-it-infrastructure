/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('Document', {
    DocumentID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    RequesterID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    },
    RequestDate: {
      type: DataTypes.DATE,
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    DocHash: {
      type: DataTypes.CHAR(32),
      allowNull: true
    },
    Alias: {
      type: DataTypes.STRING(255),
      allowNull: true
    }
  }, {
    tableName: 'Document'
  });
};
