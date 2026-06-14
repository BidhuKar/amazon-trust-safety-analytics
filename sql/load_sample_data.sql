-- Seed sample data for mini Black Friday phishing spike

INSERT INTO dim_customer (customer_id, signup_date, country, device_type, is_prime_member, lifetime_orders, risk_segment) VALUES
('C1001', '2022-03-15', 'US', 'mobile', TRUE, 42, 'high'),
('C1002', '2023-11-02', 'US', 'web', FALSE, 5, 'medium'),
('C1003', '2021-08-09', 'UK', 'both', TRUE, 87, 'low'),
('C1004', '2024-06-21', 'IN', 'mobile', FALSE, 12, 'medium');

INSERT INTO fact_phishing_messages (message_id, received_ts, channel, customer_id, subject_line, message_body, cta_type, brand_mimicked, reported_source, is_ai_like, label_is_phishing, model_phish_score) VALUES
('M5001', '2025-11-25 08:13:22', 'email',    'C1001', 'Your Amazon account has been locked – action now',   'We detected unusual activity. Sign in within 24 hours to avoid permanent suspension.', 'reset_password',  'ShopHub', 'customer_report', TRUE,  TRUE, NULL),
('M5002', '2025-11-25 09:47:03', 'sms',      'C1002', '[ShopHub] Confirm your Black Friday order',         'Tap here to confirm your TV order or it will be cancelled: http://shophub-tv-sale.io', 'confirm_order',   'ShopHub', 'customer_report', TRUE,  TRUE, NULL),
('M5003', '2025-11-26 12:01:55', 'whatsapp', 'C1004', 'Exclusive refund on your last purchase',            'You are eligible for an instant refund. Verify card details on our secure portal.',     'refund_offer',    'ShopHub', 'spam_trap',       TRUE,  TRUE, NULL),
('M5004', '2025-11-26 13:22:10', 'email',     NULL,   'Get a $100 ShopHub gift card today',               'Limited-time offer for selected users. Claim your $100 gift card here.',               'gift_card',       'ShopHub', 'partner_feed',    TRUE,  TRUE, NULL),
('M5005', '2025-11-26 14:05:37', 'email',    'C1003', 'Your ShopHub order #8293 has shipped',              'Your order has shipped. Track it from your account dashboard.',                        'other',           'ShopHub', 'system_notification', FALSE, FALSE, NULL);

INSERT INTO fact_phishing_interactions (interaction_id, message_id, customer_id, interaction_ts, action_type, device_type, landing_page_domain) VALUES
('I9001', 'M5001', 'C1001', '2025-11-25 08:20:11', 'opened',              'mobile', 'spoof_shophub-login.com'),
('I9002', 'M5001', 'C1001', '2025-11-25 08:21:02', 'clicked_link',        'mobile', 'spoof_shophub-login.com'),
('I9003', 'M5001', 'C1001', '2025-11-25 08:21:55', 'entered_credentials', 'mobile', 'spoof_shophub-login.com'),
('I9004', 'M5002', 'C1002', '2025-11-25 09:48:10', 'clicked_link',        'web',    'spoof_shophub-orders.net'),
('I9005', 'M5003', 'C1004', '2025-11-26 12:05:22', 'ignored',             'mobile', NULL),
('I9006', 'M5005', 'C1003', '2025-11-26 14:06:10', 'opened',              'both',   'legit_shophub.com');

INSERT INTO fact_login_activity (login_id, customer_id, login_ts, channel, ip_country, is_success, is_unusual_device, is_unusual_location, is_flagged_suspicious) VALUES
('L7001', 'C1001', '2025-11-25 08:22:40', 'web',    'RU', TRUE,  TRUE,  TRUE,  TRUE),
('L7002', 'C1001', '2025-11-24 19:10:03', 'mobile', 'US', TRUE,  FALSE, FALSE, FALSE),
('L7003', 'C1002', '2025-11-25 10:01:17', 'web',    'US', TRUE,  FALSE, FALSE, FALSE),
('L7004', 'C1003', '2025-11-26 14:10:55', 'web',    'UK', TRUE,  FALSE, FALSE, FALSE),
('L7005', 'C1004', '2025-11-26 12:10:15', 'mobile', 'IN', FALSE, FALSE, FALSE, FALSE);

INSERT INTO fact_orders (order_id, customer_id, order_ts, order_value, payment_method, is_refunded, is_chargeback, is_fraud_related) VALUES
('O3001', 'C1001', '2025-11-20 16:05:21', 129.99, 'credit_card', FALSE, FALSE, FALSE),
('O3002', 'C1001', '2025-11-25 09:05:32', 899.00, 'credit_card', FALSE, TRUE,  TRUE),
('O3003', 'C1002', '2025-11-26 11:22:09',  45.50, 'debit_card',  FALSE, FALSE, FALSE),
('O3004', 'C1003', '2025-11-26 14:03:44',  59.90, 'paypal',      FALSE, FALSE, FALSE),
('O3005', 'C1004', '2025-11-24 10:41:08',  19.99, 'credit_card', TRUE,  FALSE, FALSE);

INSERT INTO fact_security_incidents (incident_id, customer_id, incident_ts, incident_type, root_cause, estimated_loss_usd) VALUES
('SI8001', 'C1001', '2025-11-25 12:30:00', 'account_takeover',   'phishing', 0.00),
('SI8002', 'C1001', '2025-11-27 09:15:10', 'payment_fraud',      'phishing', 899.00),
('SI8003', 'C1002', '2025-11-28 16:45:39', 'account_monitoring', 'phishing', 0.00);

INSERT INTO dim_campaign (campaign_id, launch_ts, campaign_type, message_template, target_segment) VALUES
('CMP01', '2025-11-24 07:00:00', 'email_warning', 'Beware of fake Black Friday deals pretending to be us.', 'high'),
('CMP02', '2025-11-26 09:00:00', 'in_app_banner', 'Never enter your password after clicking on a link.',    'medium');

INSERT INTO fact_campaign_exposure (exposure_id, campaign_id, customer_id, exposed_ts, viewed, clicked_learn_more) VALUES
('E6001', 'CMP01', 'C1001', '2025-11-24 07:05:15', TRUE,  TRUE),
('E6002', 'CMP01', 'C1003', '2025-11-24 07:07:02', FALSE, FALSE),
('E6003', 'CMP02', 'C1002', '2025-11-26 09:05:48', TRUE,  FALSE),
('E6004', 'CMP02', 'C1004', '2025-11-26 09:06:10', TRUE,  TRUE);
