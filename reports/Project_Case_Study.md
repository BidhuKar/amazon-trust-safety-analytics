# Project Case Study

This repository contains a synthetic Trust & Safety dataset and analysis artifacts for a phishing and fraud risk case study. The work is structured to support both technical review and recruiter-friendly storytelling.

## Project scope

- Model a phishing wave using synthetic message, interaction, login, order, and security incident tables.
- Build a reproducible Python pipeline that aggregates customer behavior and exposures.
- Add an attribution path tying suspicious login events and fraud orders to phishing exposure.
- Score customers with a simple, interpretable risk model and bucketed risk tiers.
- Present the work with SQL queries, interactive notebooks, and a polished portfolio page.

## Key outputs

- `output/features/customer_features.csv`: customer-level metrics including phishing exposure, suspicious logins, and downstream fraud counts.
- `output/scores/customer_risk_scores.csv`: interpretable risk scores and qualitative buckets.
- `output/anomalies/login_anomalies.csv`: IsolationForest anomaly flags for login events.
- `notebooks/01_data_pipeline_walkthrough.ipynb`: pipeline walkthrough for data preparation and attribution feature engineering.
- `notebooks/02_analysis_and_visualization.ipynb`: analysis notebook for attribution signals and risk segmentation.
- `reports/trust-safety-portfolio-magical.html`: case study narrative and visual presentation.

## Reproducibility

Install the pinned Python environment from `requirements.txt`, then run:

```bash
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python python/data_preparation.py
python python/anomaly_detection.py
python python/risk_scoring.py
```

## Attribution logic

The pipeline now computes two provenance-aware metrics:

- `suspicious_logins_after_phish`: suspicious logins within 2 days after a labeled phishing message.
- `fraud_orders_after_phish`: fraud-related orders within 3 days after a labeled phishing message.

These metrics are designed to make the Trust & Safety narrative explicit in downstream scoring and visualization.