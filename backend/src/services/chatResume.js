import { embeddings } from './embeddings.js';
import { searchVectors } from './qdrant.js';
import Groq from 'groq-sdk';
import { getHistory, saveHistory } from './redis.js';
import * as dotenv from 'dotenv';
dotenv.config();

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export const chatResume = async (question, userId, conversationId = 'default') => {
  // 1. Embed the question
  const queryVector = await embeddings.embedQuery(question);

  // 2. Search resume chunks
  const chunks = await searchVectors(`resume_${userId}`, queryVector, 5);

  const context = chunks
    .map((text, i) => `Source ${i + 1}:\n${text}`)
    .join('\n\n--\n\n');

  // 3. Redis conversation history
  const history = await getHistory(`${userId}:${conversationId}`);

  let historyContext = '';
  if (history.length > 0) {
    historyContext = '\n\nPrevious conversation (most recent first):\n';
    [...history].reverse().forEach((item) => {
      historyContext += `Q: ${item.question}\nA: ${item.answer}\n\n`;
    });
  }

  const prompt = `You are a helpful assistant that answers questions about a person's resume and professional background.

${historyContext}Current question: ${question}

Use ONLY the context provided below to answer. Be concise and direct.

Context from resume:
${context}

If the answer is not found in the context, say:
"I don't have that information in your resume."

Answer:`;

  const response = await groq.chat.completions.create({
    model: 'llama-3.1-8b-instant',
    messages: [{ role: 'user', content: prompt }],
  });

  const reply = response.choices[0]?.message?.content;

  await saveHistory(`${userId}:${conversationId}`, [
    ...history,
    { question, answer: reply },
  ]);

  return reply;
};
