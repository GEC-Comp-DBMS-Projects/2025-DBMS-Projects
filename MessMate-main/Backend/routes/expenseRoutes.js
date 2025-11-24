const express = require('express');
const router = express.Router();
const { getTotalExpenses, addExpense,getSummary } = require('../controllers/expenseController');
const {verifyToken} = require('../middleware/authMiddleware');

// Use verifyToken middleware
router.get('/total/:userId', verifyToken, getTotalExpenses);
router.post('/add', verifyToken, addExpense);
router.get('/summary/:userId', verifyToken, getSummary);

module.exports = router;
