// routes/builds.js
import express from 'express';
import { nanoid } from 'nanoid';
import pool from "../../config/db.js";
import { body, validationResult } from 'express-validator';

const router = express.Router();

/**
 * POST /api/builds
 */
router.post(
  '/',
  body('components').isObject().withMessage('components required'),
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { title, description, components, meta } = req.body;
    const id = nanoid(10);
    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      const payload = { components, meta };

      await conn.query(
        'INSERT INTO builds (id, title, description, source, payload) VALUES (?, ?, ?, ?, ?)',
        [id, title || null, description || null, meta?.source || 'app', JSON.stringify(payload)]
      );

      for (const [type, comp] of Object.entries(components || {})) {
        await conn.query(
          'INSERT INTO build_components (build_id, component_type, component_id, snapshot) VALUES (?, ?, ?, ?)',
          [id, type, comp?.id || null, JSON.stringify(comp || {})]
        );
      }

      await conn.commit();
      res.json({
        success: true,
        id,
        url: `${process.env.PUBLIC_BASE_URL || 'http://10.102.232.54:3000'}/build/${id}`,
      });
    } catch (err) {
      await conn.rollback();
      console.error('Build save error', err);
      res.status(500).json({ error: 'Unable to save build' });
    } finally {
      conn.release();
    }
  }
);

/**
 * GET /api/builds/:id
 */
router.get('/:id', async (req, res) => {
  const id = req.params.id;
  try {
    const [rows] = await pool.query('SELECT * FROM builds WHERE id = ?', [id]);
    if (!rows?.length) return res.status(404).json({ error: 'Not found' });

    const build = rows[0];
    const [comps] = await pool.query(
      'SELECT component_type, component_id, snapshot FROM build_components WHERE build_id = ?',
      [id]
    );

    res.json({
      id: build.id,
      title: build.title,
      description: build.description,
      created_at: build.created_at,
      payload: build.payload ? JSON.parse(build.payload) : null,
      components: comps.map(c => ({
        type: c.component_type,
        id: c.component_id,
        snapshot: JSON.parse(c.snapshot),
      })),
    });
  } catch (err) {
    console.error('Fetch build error', err);
    res.status(500).json({ error: 'Server error' });
  }
});

export default router;
