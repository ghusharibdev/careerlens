import express from 'express';
import { verifyFirebaseToken } from '../middleware/verifyFirebaseToken.js';
import { chatResume } from '../services/chatResume.js';

const router = express.Router();

// POST /api/chat
router.post('/', verifyFirebaseToken, async (req, res) => {
  try {
    const { question, conversationId } = req.body;
    if (!question) {
      return res.status(400).json({ error: 'question is required' });
    }
    const answer = await chatResume(question, req.user.uid, conversationId);
    res.json({ success: true, answer });
  } catch (err) {
    console.error('Chat error:', err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
