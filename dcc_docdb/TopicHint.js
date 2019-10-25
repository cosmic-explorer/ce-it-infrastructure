/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('TopicHint', {
    TopicHintID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    SessionTalkID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    TopicID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    }
  }, {
    tableName: 'TopicHint'
  });
};
