-- Fraud funnel: from phishing message to financial loss

-- 1) Stage counts per customer
SELECT
    c.customer_id,
    COUNT(DISTINCT m.message_id)                              AS messages,
    COUNT(DISTINCT CASE WHEN i.action_type IN ('opened','clicked_link') THEN i.interaction_id END) AS engaged,
    COUNT(DISTINCT CASE WHEN i.action_type = 'entered_credentials' THEN i.interaction_id END)       AS credentials_entered,
    COUNT(DISTINCT CASE WHEN la.is_flagged_suspicious THEN la.login_id END)                         AS suspicious_logins,
    COUNT(DISTINCT CASE WHEN o.is_fraud_related THEN o.order_id END)                                AS fraud_orders
FROM dim_customer c
LEFT JOIN fact_phishing_messages m
    ON m.customer_id = c.customer_id AND m.label_is_phishing = TRUE
LEFT JOIN fact_phishing_interactions i
    ON i.message_id = m.message_id
LEFT JOIN fact_login_activity la
    ON la.customer_id = c.customer_id
       AND la.login_ts >= m.received_ts
       AND la.login_ts <= m.received_ts + INTERVAL '2 days'
LEFT JOIN fact_orders o
    ON o.customer_id = c.customer_id
       AND o.order_ts >= m.received_ts
       AND o.order_ts <= m.received_ts + INTERVAL '3 days'
GROUP BY c.customer_id
ORDER BY fraud_orders DESC, suspicious_logins DESC;
