## TrustSight Analytics — Trust & Safety abuse intelligence

## Overview

I created TrustSight Analytics to show how a retailer-style Trust & Safety dataset can be assembled, analyzed, and presented. I used synthetic customer, phishing, login, order and incident records to model a phishing wave and downstream security impact, then built a small analysis pipeline that turns raw CSVs into feature tables, anomaly scores, and risk scores.

## What this repo contains

I kept the project organized so the artifacts are easy to follow:

- `data/raw/` contains the cleaned input CSVs for the pipeline, including customer, phishing message, interaction, login, order, incident, campaign, and campaign exposure tables.
- `sql/` contains the schema and analytic queries that I used to explore the dataset and write the case study.
- `python/` contains the scripts I use to build the feature table, run anomaly detection on login signals, and score customers for risk.
- `notebooks/` contains interactive walkthroughs for the pipeline and the attribution analysis.
- `reports/trust-safety-portfolio-magical.html` is the portfolio page that bundles the main findings into a recruiter-ready narrative with visuals.
- `dashboards/Dashboard_Screenshots/` stores the chart images included in the portfolio page.
- `requirements.txt` pins the reproducible Python environment for this project.
- `output/` stores the generated artifacts produced by the Python workflow.

## What I built

I focused this project on a few concrete outputs:

- a trust & safety schema and seeded dataset in SQL
- a Python feature pipeline that joins raw data into per-customer aggregates
- an attribution path that links suspicious logins and fraud orders back to phishing exposure
- a prototype anomaly detection experiment on login behavior
- a simple, interpretable risk score that combines phishing exposure, suspicious logins, and order-level signal
- notebook walkthroughs that document the pipeline and attribution analysis
- a portfolio page that showcases the visuals, narrative, and SQL evidence together

## How to run the project

From the repo root, I recommend these steps:

   cd amazon-trust-safety-analytics

1) Create and activate a Python virtual environment:

   # python -m venv .venv
   # source .venv/bin/activate

2) Install the dependencies:

   # python -m pip install --upgrade pip
   # python -m pip install -r requirements.txt

3) Run the pipeline:

   # python python/data_preparation.py
   # python python/anomaly_detection.py
   # python python/risk_scoring.py

4) View the portfolio page:

   - **Direct link:** [Open portfolio page](reports/trust-safety-portfolio-magical.html)
   - **Or run a local server and navigate to** `http://localhost:8000/reports/trust-safety-portfolio-magical.html`:
   
   python -m http.server 8000

5) Run the notebooks for the full walkthrough:

   # python -m notebook
   # then open notebooks/01_data_pipeline_walkthrough.ipynb and notebooks/02_analysis_and_visualization.ipynb

## What the scripts do

- `python/data_preparation.py` loads the raw CSV tables, normalizes timestamps, joins data into customer-level aggregates, and saves `output/features/customer_features.csv`.
- `python/anomaly_detection.py` loads login events, encodes simple features, trains an `IsolationForest`, and saves `output/anomalies/login_anomalies.csv`.
- `python/risk_scoring.py` loads the customer features, computes a weighted score, buckets customers into risk tiers, and saves `output/scores/customer_risk_scores.csv`.

## What I produce

- `output/features/customer_features.csv`: customer-level metrics for phishing exposure, interactions, suspicious login events, orders, and incidents
- `output/anomalies/login_anomalies.csv`: anomaly scores and flags for login events
- `output/scores/customer_risk_scores.csv`: prototype risk scores and qualitative buckets

## How to interpret the outputs

I use `output/features/customer_features.csv` as the foundation for scoring and analysis. It shows how message volume, click behavior, suspicious logins, and order outcomes combine into risk signal.

The `risk_scoring.py` result is a prototype, not a production model. I built it to be understandable and easy to explain.

The portfolio HTML is the final presentation layer: it is intended to make the core insights readable and to connect the visuals back to the underlying SQL and data.

