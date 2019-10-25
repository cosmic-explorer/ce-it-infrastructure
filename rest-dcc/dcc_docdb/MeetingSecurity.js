/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('MeetingSecurity', {
    MeetingSecurityID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    ConferenceID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    GroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'MeetingSecurity'
  })
}
