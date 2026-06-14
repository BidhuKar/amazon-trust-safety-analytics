"""Simple customer risk scoring for the TrustSight Analytics project.

This module reads the customer_features table produced by data_preparation,
computes a simple interpretable risk score, and saves the result.
"""

from pathlib import Path
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
FEATURES_DIR = ROOT / "output" / "features"
SCORES_DIR = ROOT / "output" / "scores"
SCORES_DIR.mkdir(parents=True, exist_ok=True)


def load_features() -> pd.DataFrame:
    path = FEATURES_DIR / "customer_features.csv"
    if not path.exists():
        raise FileNotFoundError(
            f"Expected feature file at {path}. Run data_preparation.py first."
        )
    return pd.read_csv(path)


def compute_risk_scores(df: pd.DataFrame) -> pd.DataFrame:
    feats = df.copy()

    # Pick numeric columns we expect to be present
    msg_col = "phish_messages" if "phish_messages" in feats.columns else None
    cred_col_candidates = [
        c for c in feats.columns if "entered_credentials" in c or "credential" in c
    ]
    cred_col = cred_col_candidates[0] if cred_col_candidates else None
    susp_col = (
        "suspicious_login_events"
        if "suspicious_login_events" in feats.columns
        else None
    )
    susp_after_col = (
        "suspicious_logins_after_phish"
        if "suspicious_logins_after_phish" in feats.columns
        else None
    )
    fraud_after_col = (
        "fraud_orders_after_phish"
        if "fraud_orders_after_phish" in feats.columns
        else None
    )
    orders_cnt_col = "orders_cnt" if "orders_cnt" in feats.columns else None
    loss_flag = "incident_count" if "incident_count" in feats.columns else None

    # Weighted sum; all missing parts treated as zero
    score = 0
    if msg_col:
        score += 0.5 * feats[msg_col]
    if cred_col:
        score += 4.0 * feats[cred_col]
    if susp_col:
        score += 1.5 * feats[susp_col]
    if susp_after_col:
        score += 3.0 * feats[susp_after_col]
    if fraud_after_col:
        score += 7.0 * feats[fraud_after_col]
    if orders_cnt_col:
        score += 0.1 * feats[orders_cnt_col]
    if loss_flag:
        score += 5.0 * (feats[loss_flag] > 0).astype(float)

    feats["risk_score_raw"] = score

    # Normalize into 0–100
    if feats["risk_score_raw"].max() > 0:
        feats["risk_score"] = (
            100 * feats["risk_score_raw"] / feats["risk_score_raw"].max()
        )
    else:
        feats["risk_score"] = 0.0

    # Buckets: low / medium / high / critical
    bins = [-1, 20, 40, 70, 100]
    labels = ["low", "medium", "high", "critical"]
    feats["risk_bucket"] = pd.cut(feats["risk_score"], bins=bins, labels=labels)

    return feats


def main():
    features = load_features()
    scored = compute_risk_scores(features)
    out_path = SCORES_DIR / "customer_risk_scores.csv"
    scored.to_csv(out_path, index=False)
    print(f"Saved customer risk scores to {out_path}")


if __name__ == "__main__":
    main()
