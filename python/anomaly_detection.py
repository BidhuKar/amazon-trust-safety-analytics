"""Anomaly detection experiments for the TrustSight Analytics project.

This module trains a simple IsolationForest model on login activity
and flags the most unusual login events.
"""

from pathlib import Path

import pandas as pd
from sklearn.ensemble import IsolationForest


ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = ROOT / "data" / "raw"
ANOM_DIR = ROOT / "output" / "anomalies"
ANOM_DIR.mkdir(parents=True, exist_ok=True)


def load_login_data() -> pd.DataFrame:
    df = pd.read_csv(RAW_DIR / "fact_login_activity_clean.csv")
    if "login_ts" in df.columns:
        df["login_ts"] = pd.to_datetime(df["login_ts"], errors="coerce")
    return df


def build_login_features(df: pd.DataFrame) -> pd.DataFrame:
    tmp = df.copy()

    # Time features
    if "login_ts" in tmp.columns:
        tmp["hour"] = tmp["login_ts"].dt.hour
        tmp["dayofweek"] = tmp["login_ts"].dt.dayofweek
    else:
        tmp["hour"] = 0
        tmp["dayofweek"] = 0

    # Encode simple categorical features
    for col in ["channel", "ip_country"]:
        if col in tmp.columns:
            tmp[col] = tmp[col].astype("category").cat.codes
        else:
            tmp[col] = 0

    # Binary flags
    if "is_unusual_device" in tmp.columns:
        tmp["is_unusual_device"] = tmp["is_unusual_device"].astype(int)
    else:
        tmp["is_unusual_device"] = 0

    if "is_unusual_location" in tmp.columns:
        tmp["is_unusual_location"] = tmp["is_unusual_location"].astype(int)
    else:
        tmp["is_unusual_location"] = 0

    feature_cols = [
        "hour",
        "dayofweek",
        "channel",
        "ip_country",
        "is_unusual_device",
        "is_unusual_location",
    ]

    return tmp, feature_cols


def run_isolation_forest(df: pd.DataFrame, feature_cols: list) -> pd.DataFrame:
    model = IsolationForest(
        n_estimators=200,
        contamination=0.02,
        random_state=42,
    )

    X = df[feature_cols]
    model.fit(X)

    df["anomaly_score"] = model.decision_function(X)
    df["is_anomaly"] = model.predict(X) == -1

    return df


def main():
    logins = load_login_data()
    feats, feature_cols = build_login_features(logins)
    scored = run_isolation_forest(feats, feature_cols)

    out_path = ANOM_DIR / "login_anomalies.csv"
    scored.to_csv(out_path, index=False)
    print(f"Saved login anomaly scores to {out_path}")


if __name__ == "__main__":
    main()