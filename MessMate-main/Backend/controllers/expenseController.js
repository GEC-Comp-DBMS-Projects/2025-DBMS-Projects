const db = require('../config/db');

const getTotalExpenses = async (req, res) => {
  const userId = req.params.userId;
  const period = req.query.period || 'week';


  try {
    let dateCondition = '';
    if (period === 'week') dateCondition = `YEARWEEK(date, 1) = YEARWEEK(CURDATE(), 1)`;
    else if (period === 'month') dateCondition = `MONTH(date) = MONTH(CURDATE()) AND YEAR(date) = YEAR(CURDATE())`;
    else if (period === 'year') dateCondition = `YEAR(date) = YEAR(CURDATE())`;

    const [totalRows] = await db.execute(
      `SELECT IFNULL(SUM(price), 0) AS total FROM expenses WHERE user_id = ? AND ${dateCondition}`,
      [userId]
    );
    const total = totalRows[0].total;

    const [byCategory] = await db.execute(
      `SELECT category, IFNULL(SUM(price), 0) AS total
       FROM expenses
       WHERE user_id = ? AND ${dateCondition}
       GROUP BY category`,
      [userId]
    );

    const [recentTransactions] = await db.execute(
    `SELECT expense_id AS id, item_name AS description, price AS amount, category, date
    FROM expenses
    WHERE user_id = ? AND date = CURDATE()
    ORDER BY created_at DESC`,
    [userId]
    );


    const recentTxWithItems = recentTransactions.map(tx => ({
      ...tx,
      items: [tx.description],
    }));

    return res.json({ total, byCategory, recentTransactions: recentTxWithItems });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Server error' });
  }
};

const addExpense = async (req, res) => {
  const { user_id, name, price, category } = req.body;

  if (!user_id || !name || !price || !category)
    return res.status(400).json({ error: 'Missing required fields' });

  try {
    const [result] = await db.execute(
      `INSERT INTO expenses (user_id, item_name, price, category, date, created_at)
       VALUES (?, ?, ?, ?, CURDATE(), NOW())`,
      [user_id, name, price, category]
    );

    return res.json({ message: 'Expense added successfully', expenseId: result.insertId });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Could not add expense' });
  }
};


const getSummary = async (req, res) => {
  const userId = req.params.userId;

  try {
    // --- Today ---
    const [todayRow] = await db.execute(
      `SELECT IFNULL(SUM(price), 0) AS total
       FROM expenses
       WHERE user_id = ? AND DATE(date) = CURDATE()`,
      [userId]
    );
    const today = todayRow[0].total;

    // --- This Week ---
    const [weekRow] = await db.execute(
      `SELECT IFNULL(SUM(price), 0) AS total
       FROM expenses
       WHERE user_id = ? AND YEARWEEK(date, 1) = YEARWEEK(CURDATE(), 1)`,
      [userId]
    );
    const week = weekRow[0].total;

    // --- This Month ---
    const [monthRow] = await db.execute(
      `SELECT IFNULL(SUM(price), 0) AS total
       FROM expenses
       WHERE user_id = ? AND MONTH(date) = MONTH(CURDATE()) AND YEAR(date) = YEAR(CURDATE())`,
      [userId]
    );
    const month = monthRow[0].total;

    // --- This Year ---
    const [yearRow] = await db.execute(
      `SELECT IFNULL(SUM(price), 0) AS total
       FROM expenses
       WHERE user_id = ? AND YEAR(date) = YEAR(CURDATE())`,
      [userId]
    );
    const year = yearRow[0].total;

    return res.json({
      today,
      week,
      month,
      year,
    });
  } catch (err) {
    console.error("❌ Error fetching expense summary:", err);
    return res.status(500).json({ error: "Server error while fetching summary" });
  }
};


module.exports = { getTotalExpenses, addExpense ,getSummary};
