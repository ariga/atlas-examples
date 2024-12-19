'use strict';

module.exports = (sequelize, DataTypes) => {
    const Task = sequelize.define('Task', {
        complete: {
            type: DataTypes.BOOLEAN,
            defaultValue: false,
        }
    });

    Task.associate = (models) => {
        Task.belongsTo(models.User, {
            foreignKey: {
                name: 'userID',
                allowNull: false
            },
            as: 'tasks'
        });
    };

    return Task;
};