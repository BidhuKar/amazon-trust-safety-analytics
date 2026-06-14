-- Campaign effectiveness: compare engagement after exposure

-- Example: did exposed users behave differently when receiving phishing?
WITH exposed AS (
    SELECT DISTINCT customer_id
    FROM fact_campaign_exposure
    WHERE viewed = TRUE
)
SELECT
    CASE WHEN e.customer_id IS NOT NULL THEN 'exposed' ELSE 'not_exposed' END AS exposure_group,
    COUNT(DISTINCT m.message_id)                                                AS phishing_messages,
    COUNT(DISTINCT CASE WHEN i.action_type = 'clicked_link' THEN i.interaction_id END)   AS clicks,
    COUNT(DISTINCT CASE WHEN i.action_type = 'entered_credentials' THEN i.interaction_id END) AS credentials_entered
FROM fact_phishing_messages m
LEFT JOIN fact_phishing_interactions i
    ON i.message_id = m.message_id
LEFT JOIN exposed e
    ON e.customer_id = m.customer_id
WHERE m.label_is_phishing = TRUE
GROUP BY exposure_group
ORDER BY exposure_group;
