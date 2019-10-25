/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('Notification', {
    NotificationID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    EmailUserID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    Type: {
      type: DataTypes.STRING(32),
      allowNull: true
    },
    ForeignID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    Period: {
      type: DataTypes.STRING(32),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    TextKey: {
      type: DataTypes.STRING(255),
      allowNull: true
    }
  }, {
    tableName: 'Notification'
  });
};
