/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('Author', {
    AuthorID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    FirstName: {
      type: DataTypes.STRING(100),
      allowNull: false
    },
    MiddleInitials: {
      type: DataTypes.STRING(16),
      allowNull: true
    },
    LastName: {
      type: DataTypes.STRING(100),
      allowNull: false
    },
    InstitutionID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    },
    Active: {
      type: DataTypes.INTEGER(11),
      allowNull: true,
      defaultValue: '1'
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    AuthorAbbr: {
      type: DataTypes.STRING(10),
      allowNull: true
    },
    FullAuthorName: {
      type: DataTypes.STRING(256),
      allowNull: true
    }
  }, {
    tableName: 'Author'
  })
}
