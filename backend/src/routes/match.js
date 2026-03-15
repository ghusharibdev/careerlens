import express from 'express';
import { verifyFirebaseToken } from '../middleware/verifyFirebaseToken.js';
import { matchJob } from '../services/matchJob.js';

const router = express.Router();

// POST /api/match
router.post('/', verifyFirebaseToken, async (req, res) => {
  try {
    const { jobDescription } = req.body;
    if (!jobDescription) {
      return res.status(400).json({ error: 'jobDescription is required' });
    }
    const result = await matchJob(jobDescription, req.user.uid);
    res.json({ success: true, result });
  } catch (err) {
    console.error('Match error:', err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
