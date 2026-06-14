-- Attack wave detection: identify spikes around Black Friday

SELECT
    DATE(received_ts)              AS event_date,
    channel,
    COUNT(*)                       AS phishing_messages
FROM fact_phishing_messages
WHERE label_is_phishing = TRUE
GROUP BY DATE(received_ts), channel
ORDER BY event_date, channel;
