import admin from 'firebase-admin';
import { createRequire } from 'module';
import { resolve } from 'path';
import * as dotenv from 'dotenv';
dotenv.config();

const require = createRequire(import.meta.url);

// Initialize Firebase Admin once
if (!admin.apps.length) {
  // resolve from backend/ root (where you run node src/index.js)
  const serviceAccount = require(resolve(process.cwd(), 'serviceAccountKey.json'));
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

export const verifyFirebaseToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No token provided' });
  }

  const token = authHeader.split('Bearer ')[1];
  try {
    const decoded = await admin.auth().verifyIdToken(token);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};