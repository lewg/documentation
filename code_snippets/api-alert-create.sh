api_key=9775a026f1ca7d1c6c5af9d94d9595a4
app_key=87ce4a24b5553d2e482ea8a8500e71b8ad4554ff
alert_id=512

curl -X POST -H "Content-type: application/json" \
-d '{
      "query": "avg(last_1h):sum:system.net.bytes_rcvd{host:host0} > 100",
      "name": "Bytes received on host0",
      "message": "We may need to add web hosts if this is consistently high."
    }' \
    "https://app.datadoghq.com/api/v1/alert?api_key=${api_key}&application_key=${app_key}"
