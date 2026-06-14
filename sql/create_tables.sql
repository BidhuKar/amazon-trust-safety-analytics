-- Schema for TrustSight Analytics Trust & Safety data model

CREATE TABLE dim_customer (
    customer_id         VARCHAR(10) PRIMARY KEY,
    signup_date         DATE,
    country             VARCHAR(2),
    device_type         VARCHAR(20),
    is_prime_member     BOOLEAN,
    lifetime_orders     INT,
    risk_segment        VARCHAR(20)
);

CREATE TABLE fact_phishing_messages (
    message_id          VARCHAR(10) PRIMARY KEY,
    received_ts         TIMESTAMP,
    channel             VARCHAR(20),
    customer_id         VARCHAR(10) REFERENCES dim_customer(customer_id),
    subject_line        TEXT,
    message_body        TEXT,
    cta_type            VARCHAR(50),
    brand_mimicked      VARCHAR(50),
    reported_source     VARCHAR(50),
    is_ai_like          BOOLEAN,
    label_is_phishing   BOOLEAN,
    model_phish_score   NUMERIC(5,2)
);

CREATE TABLE fact_phishing_interactions (
    interaction_id      VARCHAR(10) PRIMARY KEY,
    message_id          VARCHAR(10) REFERENCES fact_phishing_messages(message_id),
    customer_id         VARCHAR(10) REFERENCES dim_customer(customer_id),
    interaction_ts      TIMESTAMP,
    action_type         VARCHAR(50),
    device_type         VARCHAR(20),
    landing_page_domain VARCHAR(255)
);

CREATE TABLE fact_login_activity (
    login_id            VARCHAR(10) PRIMARY KEY,
    customer_id         VARCHAR(10) REFERENCES dim_customer(customer_id),
    login_ts            TIMESTAMP,
    channel             VARCHAR(20),
    ip_country          VARCHAR(2),
    is_success          BOOLEAN,
    is_unusual_device   BOOLEAN,
    is_unusual_location BOOLEAN,
    is_flagged_suspicious BOOLEAN
);

CREATE TABLE fact_orders (
    order_id            VARCHAR(10) PRIMARY KEY,
    customer_id         VARCHAR(10) REFERENCES dim_customer(customer_id),
    order_ts            TIMESTAMP,
    order_value         NUMERIC(10,2),
    payment_method      VARCHAR(30),
    is_refunded         BOOLEAN,
    is_chargeback       BOOLEAN,
    is_fraud_related    BOOLEAN
);

CREATE TABLE fact_security_incidents (
    incident_id         VARCHAR(10) PRIMARY KEY,
    customer_id         VARCHAR(10) REFERENCES dim_customer(customer_id),
    incident_ts         TIMESTAMP,
    incident_type       VARCHAR(50),
    root_cause          VARCHAR(50),
    estimated_loss_usd  NUMERIC(12,2)
);

CREATE TABLE dim_campaign (
    campaign_id         VARCHAR(10) PRIMARY KEY,
    launch_ts           TIMESTAMP,
    campaign_type       VARCHAR(50),
    message_template    TEXT,
    target_segment      VARCHAR(20)
);

CREATE TABLE fact_campaign_exposure (
    exposure_id         VARCHAR(10) PRIMARY KEY,
    campaign_id         VARCHAR(10) REFERENCES dim_campaign(campaign_id),
    customer_id         VARCHAR(10) REFERENCES dim_customer(customer_id),
    exposed_ts          TIMESTAMP,
    viewed              BOOLEAN,
    clicked_learn_more  BOOLEAN
);
