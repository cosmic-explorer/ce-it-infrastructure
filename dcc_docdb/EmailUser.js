/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('EmailUser', {
    EmailUserID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    Username: {
      type: DataTypes.CHAR(255),
      allowNull: false
    },
    Password: {
      type: DataTypes.CHAR(32),
      allowNull: false,
      defaultValue: ''
    },
    Name: {
      type: DataTypes.CHAR(255),
      allowNull: false
    },
    EmailAddress: {
      type: DataTypes.CHAR(255),
      allowNull: false
    },
    PreferHTML: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    CanSign: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    },
    Verified: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    },
    AuthorID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    },
    EmployeeNumber: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    }
  }, {
    timestamps: false,
    tableName: 'EmailUser'
  })
}
