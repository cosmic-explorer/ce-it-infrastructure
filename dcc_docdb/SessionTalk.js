/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('SessionTalk', {
    SessionTalkID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    SessionID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    DocumentID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    Confirmed: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    Time: {
      type: DataTypes.TIME,
      allowNull: true
    },
    HintTitle: {
      type: DataTypes.STRING(128),
      allowNull: true
    },
    Note: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'SessionTalk'
  });
};
