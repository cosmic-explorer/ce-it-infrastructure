/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('MeetingOrder', {
    MeetingOrderID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    SessionOrder: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    SessionID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    SessionSeparatorID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'MeetingOrder'
  });
};
