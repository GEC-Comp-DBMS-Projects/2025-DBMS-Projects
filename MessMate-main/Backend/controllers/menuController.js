// // controllers/menuController.js
// const db = require("../config/db");
// exports.getWeeklyMenu = async (req, res) => {
//   try {
//     const [results] = await db.query(`
//       SELECT wm.day_of_week, m.meal_type, fi.name AS item, fi.price
//       FROM weekly_menu wm
//       JOIN menu_items mi ON wm.menu_id = mi.menu_id
//       JOIN food_items fi ON mi.food_id = fi.food_id
//       JOIN meals m ON wm.meal_id = m.meal_id
//       ORDER BY wm.day_of_week, m.meal_type;
//     `);

//     const menu = {};

//     results.forEach(row => {
//       if (!menu[row.day_of_week]) {
//         menu[row.day_of_week] = { breakfast: [], lunch: [], dinner: [] };
//       }
//       menu[row.day_of_week][row.meal_type].push({
//         name: row.item,
//         price: row.price,
//       });
//     });

//     res.json({ menu });
//   } catch (err) {
//     console.error("Error fetching weekly menu:", err);
//     res.status(500).json({ error: "Failed to fetch weekly menu" });
//   }
// };



// controllers/menuController.js
const db = require("../config/db");

exports.getWeeklyMenu = async (req, res) => {
  try {
    const [results] = await db.query(`
      SELECT 
        wm.day_of_week, 
        m.meal_type, 
        fi.name AS item, 
        fi.price, 
        fi.image_url
      FROM weekly_menu wm
      JOIN menu_items mi ON wm.menu_id = mi.menu_id
      JOIN food_items fi ON mi.food_id = fi.food_id
      JOIN meals m ON wm.meal_id = m.meal_id
      ORDER BY 
        FIELD(wm.day_of_week, 'sunday','monday','tuesday','wednesday','thursday','friday','saturday'),
        FIELD(m.meal_type, 'breakfast', 'lunch', 'dinner');
    `);

    const menu = {};

    results.forEach(row => {
      if (!menu[row.day_of_week]) {
        menu[row.day_of_week] = { breakfast: [], lunch: [], dinner: [] };
      }
      menu[row.day_of_week][row.meal_type].push({
        name: row.item,
        price: row.price,
        image_url: row.image_url || null, // Include image URL
      });
    });

    res.json({ menu });
  } catch (err) {
    console.error("Error fetching weekly menu:", err);
    res.status(500).json({ error: "Failed to fetch weekly menu" });
  }
};
