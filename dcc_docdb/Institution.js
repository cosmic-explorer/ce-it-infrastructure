/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('Institution', {
    InstitutionID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    ShortName: {
      type: DataTypes.STRING(40),
      allowNull: false,
      defaultValue: ''
    },
    LongName: {
      type: DataTypes.STRING(80),
      allowNull: false,
      defaultValue: ''
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    }
  }, {
    tableName: 'Institution'
  });
};
