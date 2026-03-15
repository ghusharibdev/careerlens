import { createClient } from 'redis';
import * as dotenv from 'dotenv';
dotenv.config();

const client = createClient({ url: process.env.REDIS_URL });

client.on('error', (err) => console.error('Redis error:', err));

await client.connect();

export const getHistory = async (conversationId) => {
  const data = await client.get(`chat:${conversationId}`);
  return data ? JSON.parse(data) : [];
};

export const saveHistory = async (conversationId, history) => {
  // Keep last 10 exchanges, expire after 1 hour
  const trimmed = history.slice(-10);
  await client.setEx(`chat:${conversationId}`, 3600, JSON.stringify(trimmed));
};
