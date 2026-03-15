import { HuggingFaceTransformersEmbeddings } from '@langchain/community/embeddings/hf_transformers';
 
// Initialize once at module load — same model you use in FinChat
export const embeddings = new HuggingFaceTransformersEmbeddings({
  model: 'Xenova/all-MiniLM-L6-v2',
});
 