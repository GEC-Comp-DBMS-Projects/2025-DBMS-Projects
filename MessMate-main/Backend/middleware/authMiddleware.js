    const jwt = require("jsonwebtoken");
    const SECRET_KEY = process.env.SECRET_KEY || "your_secret_key";

    exports.verifyToken = (req, res, next) => {
      const authHeader = req.headers["authorization"];
      if (!authHeader)
        return res.status(401).json({ error: "No token provided" });

      const token = authHeader.split(" ")[1];
      jwt.verify(token, SECRET_KEY, (err, user) => {
        if (err) return res.status(403).json({ error: "Invalid token" });
        req.user = user; // ✅ Save user info to request
        next();
      });
    };