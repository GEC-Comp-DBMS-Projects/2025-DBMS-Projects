const { DataTypes } = require('sequelize');
module.exports = (sequelize) => {
  return sequelize.define('Form16Detail', {
    id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
    user_id: { type: DataTypes.STRING },
    name: { type: DataTypes.STRING },
    pan: { type: DataTypes.STRING },
    assessment_year: { type: DataTypes.STRING },
    gross_income: { type: DataTypes.STRING },
    tds_amount: { type: DataTypes.STRING },
    employer_name: { type: DataTypes.STRING },
    date_uploaded: { type: DataTypes.STRING }
  }, {
    tableName: 'form16_details',
    timestamps: false
  });
};