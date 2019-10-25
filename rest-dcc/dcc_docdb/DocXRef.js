/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('DocXRef', {
    DocXRefID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    DocRevID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    DocumentID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    Version: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    Project: {
      type: DataTypes.STRING(32),
      allowNull: true
    }
  }, {
    tableName: 'DocXRef'
  });
};
