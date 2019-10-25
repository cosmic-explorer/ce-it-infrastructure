/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('Topic', {
    TopicID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    ShortDescription: {
      type: DataTypes.STRING(64),
      allowNull: true,
      defaultValue: ''
    },
    LongDescription: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'Topic'
  });
};
