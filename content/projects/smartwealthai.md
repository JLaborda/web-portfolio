---
title: SmartWealthAI
summary: "Portfolio monorepo for finance ML engineering: a Credit Scoring System (CSS) demo with application mart → WOE/IV + XGBoost → FastAPI scoring and PSI monitoring, plus a shipped Magic Formula equity screening demo. Spec-driven, local-first, with optional ephemeral AWS Fargate serve."
problem: "Hiring managers need proof of end-to-end ML/MLOps in fintech—not notebooks alone. Credit risk and investing each need clear domain boundaries, reproducible demos on public data (no live bank BFSI), and serving/monitoring patterns that map to how production systems are shaped."
architecture_image: /images/projects/smartwealthai-credit-architecture.png
architecture_image_alt: "SmartWealthAI credit module architecture showing Kaggle extracts and book samples flowing through a mart builder into an application mart; WOE/IV and XGBoost training with MLflow logging and a pipeline artifact; a PSI monitor for reference-versus-recent drift; and Docker-based batch scoring plus a FastAPI scoring service, with optional ECR and ECS Fargate for a demo."
decisions:
  - "Domain-first monorepo (credit/, investing/, platform/) so each product has its own language and README; no blended “AI finance app” API between domains."
  - "Credit CSS follows a book-shaped pipeline: public demo data → application mart → WOE/IV feature selection (IV ≥ 0.02) → XGBoost → scaled credit score; rank-only first (no production cutoff or profit trade-off yet)."
  - "Hermetic CI and fixture-first paths so PR tests never call live SimFin, yfinance, or competition downloads; real extracts stay local/gitignored."
  - "uv workspace packaging for lean per-domain deps; Spec Kit living specs under specs/ drive delivery before code."
  - "Serving starts local (CLI batch + FastAPI /score and /drivers from the same joblib artifact); ephemeral ECR/ECS Fargate is a stretch demo, not a full AWS cutover."
results: "Portfolio release v0.2.0 ships both demos: Credit CSS (mart, WOE/XGB fit→joblib, FastAPI score/drivers, local PSI CLI, doctor readiness, Friday rehearsal guide) and Investing Magic Formula (SimFin → PIT lake → ROC+EY → top-30 EW portfolio → Streamlit + MLflow). Results are demo-bounded on public/book/competition-shaped data—no live bank metrics and no claimed production AUC/KS. Known gaps remain: OptBinning scorecard (ch.6), deeper monitoring/explainability, and broader platform orchestration."
stack:
  - "Python 3.11+ / uv workspace"
  - "pandas, XGBoost, WOE/IV, MLflow"
  - "FastAPI scoring service + Docker batch score"
  - "PSI drift CLI (reference vs recent)"
  - "Streamlit investing dashboard"
  - "SimFin (investing demo data)"
  - "Terraform / ECR / ECS Fargate (ephemeral CSS serve stretch)"
  - "GitHub Actions domain CI matrix"
repo_url: https://github.com/JLaborda/SmartWealthAI
---

SmartWealthAI is the primary hiring case study on this site. The architecture diagram above is the Credit CSS path corresponding to portfolio v0.2.0. Fraud detection is not started; investing Phase 2 Quantitative Value is not in active execution.
