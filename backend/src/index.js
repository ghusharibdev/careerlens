import express from 'express';
import cors from 'cors';
import * as dotenv from 'dotenv';
dotenv.config();

import resumeRouter from './routes/resume.js';
import matchRouter from './routes/match.js';
import chatRouter from './routes/chat.js';

const app = express();

app.use(cors({ origin: '*' }));

app.use(express.json());

app.use('/api/resume', resumeRouter);
app.use('/api/match', matchRouter);
app.use('/api/chat', chatRouter);

app.get('/health', (_, res) => res.json({ status: 'ok' }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 CareerLens backend running on port ${PORT}`));
