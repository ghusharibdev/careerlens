# CareerLens 🎯

AI-powered job application tracker. Upload your resume once, paste any job description, and get an instant match score, skill gaps, talking points and interview questions — all grounded in your actual resume via RAG.

---

## Stack

- **Flutter** — Mobile app (Android/iOS), MVVM + Riverpod
- **Firebase** — Auth, Firestore, Storage
- **Node.js + Express** — Backend API
- **LangChain.js** — RAG pipeline (same pattern as FinChat Analyzer)
- **Qdrant** — Vector store (per-user collections)
- **Groq** — LLM inference (llama-3.1-8b-instant, free)
- **HuggingFace Transformers** — Free local embeddings (Xenova/all-MiniLM-L6-v2)
- **Redis** — Chat conversation history

---

## Folder Structure

```
careerlens/
├── flutter/
│   └── lib/
│       ├── core/
│       │   ├── constants/     # API endpoints
│       │   ├── network/       # Dio client + Firebase token interceptor
│       │   ├── theme/         # AppTheme (dark, amber accent)
│       │   └── utils/         # Shared widgets
│       ├── features/
│       │   ├── auth/          # Login, Signup
│       │   ├── resume/        # Upload + embed resume
│       │   ├── jobs/          # Job list, add job
│       │   ├── match/         # AI match analysis + job detail
│       │   └── chat/          # Chat with resume (RAG)
│       ├── app_router.dart
│       └── main.dart
│
└── backend/
    └── src/
        ├── middleware/        # Firebase token verification
        ├── services/
        │   ├── embeddings.js  # Shared HuggingFace instance
        │   ├── embedResume.js # PDF → chunks → Qdrant
        │   ├── matchJob.js    # JD → RAG → structured JSON
        │   ├── chatResume.js  # Q&A over resume with Redis history
        │   └── redis.js       # Conversation history
        ├── routes/            # resume, match, chat
        └── index.js           # Express entry
```

---

## Setup

### Backend

```bash
cd backend
npm install
cp .env.example .env
# Fill in: GROQ_API_KEY, QDRANT_ENDPOINT, QDRANT_API_KEY, REDIS_URL
# Add your Firebase serviceAccountKey.json to backend/
npm run dev
```

### Flutter

```bash
cd flutter
# 1. Run: flutterfire configure  (sets up firebase_options.dart)
# 2. Uncomment firebase_options lines in main.dart
# 3. flutter pub get
# 4. flutter run
```

### Firebase Setup
1. Create project at console.firebase.google.com
2. Enable **Email/Password** auth
3. Create **Firestore** database
4. Enable **Storage**
5. Download `serviceAccountKey.json` → put in `backend/`
6. Run `flutterfire configure` in the flutter folder

### Qdrant
- Sign up free at cloud.qdrant.io
- Create a cluster, copy the endpoint URL and API key to `.env`

### Redis
- Local: `docker run -p 6379:6379 redis`
- Or use Upstash (free tier) for hosted Redis

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/resume/embed` | Upload + embed resume PDF |
| POST | `/api/match` | Match JD against resume via RAG |
| POST | `/api/chat` | Chat with resume (RAG + history) |

All endpoints require Firebase Bearer token in `Authorization` header.

---

## How the RAG Works

**Resume Embedding (once):**
PDF → LangChain PDFLoader → RecursiveCharacterTextSplitter (800 chunks, 100 overlap) → HuggingFace embeddings → Qdrant collection `resume_{userId}`

**Job Match:**
JD text → embed → similarity search top-5 resume chunks → Groq LLM → structured JSON (score, gaps, talking points)

**Resume Chat:**
Question → embed → similarity search top-5 resume chunks → Groq LLM + Redis history → answer
