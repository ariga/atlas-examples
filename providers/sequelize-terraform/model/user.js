'use strict';
module.exports = function(sequelize, DataTypes) {
  const User = sequelize.define('User', {
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        isEmail: true
      },
    },
    hobby: {
      type: DataTypes.STRING,
      allowNull: false
    },
  });

  User.associate = (models) => {
    User.hasMany(models.Task, {
      foreignKey: {
        name: 'userID',
        allowNull: false
      },
      as: 'tasks'
    });
  };

  return User;
};