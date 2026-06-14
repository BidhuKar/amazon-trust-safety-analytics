"""Data preparation for the TrustSight Analytics synthetic Trust & Safety dataset.

This module loads the cleaned CSVs produced in the SQL/EDA step,
joins them into analysis-ready tables, and exports a modeling-ready
customer-level feature table.

Run from the project root (where the `output/` folder lives):

    python -m python.data_preparation
"""

from pathlib import Path
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data" / "raw"
FEATURES_DIR = ROOT / "output" / "features"
FEATURES_DIR.mkdir(parents=True, exist_ok=True)


def load_clean_tables():
    customers = pd.read_csv(DATA / "dim_customer_clean.csv")
    messages = pd.read_csv(DATA / "fact_phishing_messages_clean.csv")
    interactions = pd.read_csv(DATA / "fact_phishing_interactions_clean.csv")
    logins = pd.read_csv(DATA / "fact_login_activity_clean.csv")
    orders = pd.read_csv(DATA / "fact_orders_clean.csv")
    incidents = pd.read_csv(DATA / "fact_security_incidents_clean.csv")

    for df, col in [
        (customers, "signup_date"),
        (messages, "received_ts"),
        (interactions, "interaction_ts"),
        (logins, "login_ts"),
        (orders, "order_ts"),
        (incidents, "incident_ts"),
    ]:
        if col in df.columns:
            df[col] = pd.to_datetime(df[col], errors="coerce")

    return {
        "customers": customers,
        "messages": messages,
        "interactions": interactions,
        "logins": logins,
        "orders": orders,
        "incidents": incidents,
    }


def build_customer_features(tables: dict) -> pd.DataFrame:
    customers = tables["customers"].copy()
    messages = tables["messages"].copy()
    interactions = tables["interactions"].copy()
    logins = tables["logins"].copy()
    orders = tables["orders"].copy()
    incidents = tables["incidents"].copy()

    # Basic phishing message volume per customer
    phishing_messages = messages[
        messages.get("label_is_phishing", False) == True
    ].copy()
    msg_counts = (
        phishing_messages.groupby("customer_id")["message_id"]
        .nunique()
        .rename("phish_messages")
        .reset_index()
    )
    msg_counts["has_phishing_history"] = True

    # Interaction behaviours (opened / clicked / entered_credentials etc.)
    action_counts = (
        interactions.groupby(["customer_id", "action_type"])["interaction_id"]
        .nunique()
        .unstack(fill_value=0)
    )
    action_counts.columns = [f"interactions_{c}" for c in action_counts.columns]
    action_counts = action_counts.reset_index()

    # Suspicious login count
    suspicious_logins = (
        logins[logins.get("is_flagged_suspicious", False) == True]
        .groupby("customer_id")["login_id"]
        .nunique()
        .rename("suspicious_login_events")
        .reset_index()
    )

    # Order metrics
    value_col_candidates = [
        "order_amount",
        "order_value",
        "amount",
        "revenue",
    ]
    value_col = next((c for c in value_col_candidates if c in orders.columns), None)

    if value_col is not None:
        order_agg = orders.groupby("customer_id")[value_col].agg(
            orders_total_value="sum",
            orders_avg_value="mean",
            orders_cnt="size",
        )
    else:
        order_agg = orders.groupby("customer_id").agg(
            orders_cnt=("order_id", "size")
        )
    order_agg = order_agg.reset_index()

    # Suspicious logins tied to phishing exposure
    phish_window_logins = pd.merge(
        phishing_messages[["customer_id", "received_ts"]],
        logins[
            [
                "customer_id",
                "login_id",
                "login_ts",
                "is_flagged_suspicious",
            ]
        ],
        on="customer_id",
        how="inner",
    )
    phish_window_logins = phish_window_logins[
        (phish_window_logins["is_flagged_suspicious"] == True)
        & (phish_window_logins["login_ts"] >= phish_window_logins["received_ts"])
        & (
            phish_window_logins["login_ts"]
            <= phish_window_logins["received_ts"] + pd.Timedelta(days=2)
        )
    ]
    suspicious_after_phish = (
        phish_window_logins.groupby("customer_id")["login_id"]
        .nunique()
        .rename("suspicious_logins_after_phish")
        .reset_index()
    )

    # Fraud orders tied to phishing exposure
    phish_window_orders = pd.merge(
        phishing_messages[["customer_id", "received_ts"]],
        orders[
            [
                "customer_id",
                "order_id",
                "order_ts",
                "is_fraud_related",
            ]
        ],
        on="customer_id",
        how="inner",
    )
    phish_window_orders = phish_window_orders[
        (phish_window_orders["is_fraud_related"] == True)
        & (phish_window_orders["order_ts"] >= phish_window_orders["received_ts"])
        & (
            phish_window_orders["order_ts"]
            <= phish_window_orders["received_ts"] + pd.Timedelta(days=3)
        )
    ]
    fraud_after_phish = (
        phish_window_orders.groupby("customer_id")["order_id"]
        .nunique()
        .rename("fraud_orders_after_phish")
        .reset_index()
    )

    # Binary incident flag
    incident_flag = (
        incidents.groupby("customer_id")["incident_id"]
        .nunique()
        .rename("incident_count")
        .reset_index()
    )

    # Start join from customers
    feats = customers[
        [
            "customer_id",
            "country",
            "device_type",
            "is_prime_member",
            "lifetime_orders",
            "risk_segment",
        ]
    ].copy()
    feats = feats.merge(msg_counts, on="customer_id", how="left")
    feats = feats.merge(action_counts, on="customer_id", how="left")
    feats = feats.merge(suspicious_logins, on="customer_id", how="left")
    feats = feats.merge(suspicious_after_phish, on="customer_id", how="left")
    feats = feats.merge(order_agg, on="customer_id", how="left")
    feats = feats.merge(fraud_after_phish, on="customer_id", how="left")
    feats = feats.merge(incident_flag, on="customer_id", how="left")

    # Fill NaNs for counts with 0 and booleans with False
    count_cols = [
        c
        for c in feats.columns
        if c
        not in ["customer_id", "country", "device_type", "risk_segment", "is_prime_member"]
    ]
    feats[count_cols] = feats[count_cols].fillna(0)
    if "has_phishing_history" in feats.columns:
        feats["has_phishing_history"] = feats["has_phishing_history"].astype(bool)

    return feats


def main():
    tables = load_clean_tables()
    features = build_customer_features(tables)
    out_path = FEATURES_DIR / "customer_features.csv"
    features.to_csv(out_path, index=False)
    print(f"Saved customer feature table to {out_path}")


if __name__ == "__main__":
    main()
