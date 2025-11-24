const express = require("express");
const router = express.Router();
const {getWeeklyMenu} = require("../controllers/menuController");

router.get("/menu/weekly", getWeeklyMenu);

module.exports = router;
