/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('Suppress', {
    SuppressID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    SecurityGroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    },
    Type: {
      type: DataTypes.STRING(32),
      allowNull: true
    },
    ForeignID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    TextKey: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    ViewSetting: {
      type: DataTypes.STRING(32),
      allowNull: true
    },
    ModifySetting: {
      type: DataTypes.STRING(32),
      allowNull: true
    }
  }, {
    tableName: 'Suppress'
  });
};
