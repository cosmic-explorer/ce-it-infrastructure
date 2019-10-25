/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('ConfigSetting', {
    ConfigSettingID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    Project: {
      type: DataTypes.STRING(32),
      allowNull: true
    },
    ConfigGroup: {
      type: DataTypes.STRING(64),
      allowNull: true
    },
    Sub1Group: {
      type: DataTypes.STRING(64),
      allowNull: true
    },
    Sub2Group: {
      type: DataTypes.STRING(64),
      allowNull: true
    },
    Sub3Group: {
      type: DataTypes.STRING(64),
      allowNull: true
    },
    Sub4Group: {
      type: DataTypes.STRING(64),
      allowNull: true
    },
    ForeignID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    Value: {
      type: DataTypes.STRING(64),
      allowNull: true
    },
    Sub1Value: {
      type: DataTypes.STRING(64),
      allowNull: true
    },
    Sub2Value: {
      type: DataTypes.STRING(64),
      allowNull: true
    },
    Sub3Value: {
      type: DataTypes.STRING(64),
      allowNull: true
    },
    Sub4Value: {
      type: DataTypes.STRING(64),
      allowNull: true
    },
    Sub5Value: {
      type: DataTypes.STRING(64),
      allowNull: true
    },
    Description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    Constrained: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'ConfigSetting'
  })
}
