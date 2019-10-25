/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('KeywordGroup', {
    KeywordGroupID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    ShortDescription: {
      type: DataTypes.STRING(32),
      allowNull: true
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
    tableName: 'KeywordGroup'
  });
};
