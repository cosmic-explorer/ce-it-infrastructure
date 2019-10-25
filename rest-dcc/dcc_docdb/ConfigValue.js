/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('ConfigValue', {
    ConfigValueID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    ConfigSettingID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    Value: {
      type: DataTypes.STRING(64),
      allowNull: true
    },
    Description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'ConfigValue'
  });
};
