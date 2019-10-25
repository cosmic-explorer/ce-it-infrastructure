/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('SignoffDependency', {
    SignoffDependencyID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    SignoffID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    PreSignoffID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'SignoffDependency'
  });
};
