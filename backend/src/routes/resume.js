import express from 'express';
import multer from 'multer';
import { verifyFirebaseToken } from '../middleware/verifyFirebaseToken.js';
import { embedResume } from '../services/embedResume.js';

const router = express.Router();
const upload = multer({ dest: 'uploads/' });

// POST /api/resume/embed
router.post('/embed', verifyFirebaseToken, upload.single('resume'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }
    await embedResume(req.file.path, req.user.uid);
    res.json({ success: true, message: 'Resume embedded successfully' });
  } catch (err) {
    console.error('Embed error:', err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
