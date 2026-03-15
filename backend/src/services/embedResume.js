import { PDFLoader } from '@langchain/community/document_loaders/fs/pdf';
import { RecursiveCharacterTextSplitter } from '@langchain/textsplitters';
import { embeddings } from './embeddings.js';
import { upsertVectors } from './qdrant.js';
import * as dotenv from 'dotenv';
dotenv.config();

export const embedResume = async (filePath, userId) => {
  // 1. Load PDF
  const loader = new PDFLoader(filePath);
  const rawDoc = await loader.load();

  // 2. Split into chunks
  const splitter = new RecursiveCharacterTextSplitter({
    chunkSize: 800,
    chunkOverlap: 100,
  });
  const chunks = await splitter.splitDocuments(rawDoc);

  // 3. Embed each chunk
  const texts = chunks.map((c) => c.pageContent);
  const vectors = await embeddings.embedDocuments(texts);

  // 4. Upsert into per-user Qdrant collection
  const collectionName = `resume_${userId}`;
  const payloads = texts.map((text) => ({ text }));
  await upsertVectors(collectionName, vectors, payloads);

  console.log(`✅ Resume embedded for user: ${userId} (${chunks.length} chunks)`);
};
