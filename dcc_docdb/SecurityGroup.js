/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('SecurityGroup', {
    GroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    Name: {
      type: DataTypes.CHAR(32),
      allowNull: false
    },
    Description: {
      type: DataTypes.CHAR(64),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    CanCreate: {
      type: DataTypes.INTEGER(11),
      allowNull: true,
      defaultValue: '0'
    },
    CanAdminister: {
      type: DataTypes.INTEGER(11),
      allowNull: true,
      defaultValue: '0'
    },
    CanView: {
      type: DataTypes.INTEGER(11),
      allowNull: true,
      defaultValue: '1'
    },
    CanConfig: {
      type: DataTypes.INTEGER(11),
      allowNull: true,
      defaultValue: '0'
    },
    DisplayInList: {
      type: DataTypes.ENUM('0', '1', '2', '3'),
      allowNull: false,
      defaultValue: '1'
    }
  }, {
    tableName: 'SecurityGroup'
  })
}
