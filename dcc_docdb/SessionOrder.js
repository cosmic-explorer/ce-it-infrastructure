/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('SessionOrder', {
    SessionOrderID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    TalkOrder: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    SessionTalkID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    TalkSeparatorID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'SessionOrder'
  });
};
