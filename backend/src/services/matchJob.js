import { embeddings } from './embeddings.js';
import { searchVectors } from './qdrant.js';
import Groq from 'groq-sdk';
import * as dotenv from 'dotenv';
dotenv.config();

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export const matchJob = async (jobDescription, userId) => {
  const collectionName = `resume_${userId}`;

  // 1. Search with JD query to get relevant chunks
  const jdVector = await embeddings.embedQuery(jobDescription);
  const jdChunks = await searchVectors(collectionName, jdVector, 6);

  // 2. Also always fetch skills/experience chunks with a fixed query
  //    so we never miss the technical skills section
  const skillsVector = await embeddings.embedQuery('technical skills experience technologies programming languages frameworks');
  const skillChunks = await searchVectors(collectionName, skillsVector, 4);

  // 3. Merge and deduplicate by content
  const seen = new Set();
  const allChunks = [];
  for (const chunk of [...jdChunks, ...skillChunks]) {
    const key = chunk.substring(0, 80);
    if (!seen.has(key)) {
      seen.add(key);
      allChunks.push(chunk);
    }
  }

  console.log('Total unique chunks:', allChunks.length);

  if (allChunks.length === 0) {
    return {
      matchScore: 0,
      matchedSkills: [],
      skillGaps: [],
      talkingPoints: ['Resume not found — please re-upload your resume first.'],
      suggestedQuestions: [],
    };
  }

  const resumeContext = allChunks
    .map((text, i) => `Resume chunk ${i + 1}:\n${text}`)
    .join('\n\n---\n\n');

  const prompt = `You are a strict and honest career coach doing a resume-to-job match analysis.

RESUME CONTENT (use ONLY what is written here — do not assume any skills):
${resumeContext}

JOB DESCRIPTION:
${jobDescription}

Rules:
- matchScore: Be REALISTIC. 80+ only if resume matches MOST job requirements. 50-70 for partial match. Below 50 for weak match. Never round to 85 by default.
- matchedSkills: ONLY skills that appear EXPLICITLY in both the resume AND job description. No guessing.
- skillGaps: Skills the job requires that are clearly NOT mentioned anywhere in the resume.
- talkingPoints: 3 talking points grounded in specific projects or experience from the resume.
- suggestedQuestions: 3 interview questions the employer would likely ask for this specific role.

Respond ONLY with this exact JSON format, no markdown, no extra text:
{
  "matchScore": <number>,
  "matchedSkills": ["skill1", "skill2"],
  "skillGaps": ["gap1", "gap2"],
  "talkingPoints": ["point1", "point2", "point3"],
  "suggestedQuestions": ["q1", "q2", "q3"]
}`;

  const response = await groq.chat.completions.create({
    model: 'llama-3.3-70b-versatile', // use bigger model for better analysis
    messages: [{ role: 'user', content: prompt }],
    temperature: 0.1,
    max_tokens: 1000,
  });

  const raw = response.choices[0]?.message?.content;
  console.log('LLM response:', raw);

  const cleaned = raw.replace(/```json|```/g, '').trim();

  try {
    return JSON.parse(cleaned);
  } catch (e) {
    console.error('JSON parse error:', cleaned);
    throw new Error('Failed to parse match result from AI');
  }
};