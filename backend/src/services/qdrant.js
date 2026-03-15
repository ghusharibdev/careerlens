import { QdrantClient } from '@qdrant/js-client-rest';
import * as dotenv from 'dotenv';
dotenv.config();

export const qdrant = new QdrantClient({
  url: process.env.QDRANT_ENDPOINT,
  apiKey: process.env.QDRANT_API_KEY,
});

// Upsert vectors into a collection (creates collection if not exists)
export const upsertVectors = async (collectionName, vectors, payloads) => {
  // Check if collection exists, create if not
  const collections = await qdrant.getCollections();
  const exists = collections.collections.some((c) => c.name === collectionName);

  if (!exists) {
    await qdrant.createCollection(collectionName, {
      vectors: { size: 384, distance: 'Cosine' }, // 384 = MiniLM-L6-v2 output size
    });
  }

  // Build points array
  const points = vectors.map((vector, i) => ({
    id: Date.now() + i,
    vector,
    payload: payloads[i],
  }));

  await qdrant.upsert(collectionName, { points });
};

// Search similar vectors
export const searchVectors = async (collectionName, queryVector, topK = 5) => {
  const results = await qdrant.search(collectionName, {
    vector: queryVector,
    limit: topK,
    with_payload: true,
  });
  return results.map((r) => r.payload.text); // return raw text chunks
};
