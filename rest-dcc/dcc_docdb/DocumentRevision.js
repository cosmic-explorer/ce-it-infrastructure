/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('DocumentRevision', {
    DocRevID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    DocumentID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    },
    SubmitterID: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    },
    DocumentTitle: {
      type: DataTypes.STRING(255),
      allowNull: false,
      defaultValue: ''
    },
    PublicationInfo: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    VersionNumber: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: '0'
    },
    Abstract: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    RevisionDate: {
      type: DataTypes.DATE,
      allowNull: true
    },
    TimeStamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
    },
    Obsolete: {
      type: DataTypes.INTEGER(4),
      allowNull: true,
      defaultValue: '0'
    },
    Keywords: {
      type: DataTypes.STRING(400),
      allowNull: true
    },
    Note: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    Demanaged: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    DocTypeID: {
      type: DataTypes.INTEGER(11),
      allowNull: true
    },
    QAcheck: {
      type: DataTypes.INTEGER(4),
      allowNull: true,
      defaultValue: '0'
    },
    Migrated: {
      type: DataTypes.INTEGER(11),
      allowNull: true,
      defaultValue: '0'
    }
  }, {
    tableName: 'DocumentRevision'
  });
};
