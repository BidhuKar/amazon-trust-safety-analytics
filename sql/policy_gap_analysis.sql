-- Policy / detection gaps: victims without clear upstream signals

-- Example: suspicious logins or fraud orders where we have no labeled phishing message
SELECT
    c.customer_id,
    la.login_ts,
    la.ip_country,
    la.is_flagged_suspicious,
    o.order_id,
    o.order_value,
    o.is_fraud_related,
    COALESCE(pm.has_phishing, FALSE) AS has_phishing_history
FROM dim_customer c
JOIN fact_login_activity la
    ON la.customer_id = c.customer_id AND la.is_flagged_suspicious = TRUE
LEFT JOIN fact_orders o
    ON o.customer_id = c.customer_id AND o.is_fraud_related = TRUE
LEFT JOIN (
    SELECT customer_id, TRUE AS has_phishing
    FROM fact_phishing_messages
    WHERE label_is_phishing = TRUE
    GROUP BY customer_id
) pm
    ON pm.customer_id = c.customer_id
ORDER BY la.login_ts;
