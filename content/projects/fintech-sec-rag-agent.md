---
title: fintech-sec-rag-agent
summary: "AWS-native Phase-1 SEC 10-K / 10-K/A qualitative signal generator for demo tickers V, MA, PYPL, XYZ, and COIN. Ingests filings into an immutable S3 lake, retrieves via OpenSearch Serverless RAG, emits hermetic factor signals with Bedrock, and warehouses durable rows to Parquet / Glue / Athena."
problem: "Hiring managers need a second fintech ML/MLOps case study next to SmartWealthAI: an AWS-native path that turns public SEC 10-K text into machine-checkable research signals with provenance—not a chat bot, ranking engine, or paper broker."
architecture_image: /images/projects/fintech-sec-rag-agent-sketch.png
architecture_image_alt: "Architecture sketch of fintech-sec-rag-agent: EDGAR 10-K / 10-K/A filings land in an immutable S3 raw lake, then Step Functions and Fargate parse, chunk, embed with Titan Text Embeddings V2, index into OpenSearch Serverless for RAG retrieval, extract hermetic signals with Bedrock Converse Claude Haiku 4.5, validate, and write durable curated Parquet via Glue and Athena in eu-west-1; CLI and API Gateway Lambda support re-emit, debug, and backfill only."
decisions:
  - "Demo universe locked to tickers V, MA, PYPL, XYZ, and COIN; forms limited to SEC 10-K and 10-K/A from EDGAR as the canonical filing source."
  - "Hermetic qualitative factor contract schema 0.1.0 with exactly five locked factors; schema validation drops uncited scored claims; insufficient evidence never invents polarity."
  - "OpenSearch Serverless is the RAG vector index for retrieval during generation only; durable signals land in S3 curated Parquet + Glue Catalog + Athena, not in OpenSearch."
  - "Primary production path is S3 raw object-created → Step Functions → ECS Fargate (index + emit + warehouse); CLI and API Gateway + Lambda are secondary re-emit / debug / backfill surfaces."
  - "Locked AWS stack in eu-west-1: Bedrock Converse Claude Haiku 4.5, Titan Text Embeddings V2 (1024-d), Terraform under infra/; research / decision-support framing—not investment advice."
  - "Explicit Phase-1 non-goals: ranking, paper broker, 10-Q / 8-K / news, and chat-first UX."
results: "The pipeline is deployed on AWS. OpenSearch indexing is the current blocker. No invented latency, accuracy, cost, or user metrics; no output screenshots. Scope remains hermetic qualitative signals for the five-ticker demo universe—research / decision-support, not investment advice."
stack:
  - "Python 3.12"
  - "AWS eu-west-1"
  - "Amazon S3 (raw lake + curated Parquet)"
  - "AWS Glue Data Catalog + Amazon Athena"
  - "Amazon OpenSearch Serverless (RAG vector index)"
  - "Amazon Bedrock Converse (Claude Haiku 4.5)"
  - "Amazon Titan Text Embeddings V2 (1024-d)"
  - "Step Functions + ECS Fargate (primary path)"
  - "API Gateway + Lambda (secondary re-emit)"
  - "Terraform (infra/)"
repo_url: https://github.com/JLaborda/fintech-sec-rag-agent
---

fintech-sec-rag-agent is the second hiring case study on this site. The architecture sketch above is the Phase-1 path documented in the public repository README and `specs/001-10k-signal-demo`. Ranking, paper-broker simulation, non-10-K sources, and chat-first UX are out of scope for this phase.
