curl -X 'POST' \
  'http://localhost:8000/api/account/send_push_notification' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc1NzkyODAsImV4cCI6MTc4NzY2NTY4MH0.vz0J9B6WvMA-We-E8pNamP2SsWIrLLzlGE3K4taN_VI' \
  -H 'Content-Type: application/json' \
  -d '{
  "user_id": "user_id",
  "notification_type": "message",
  "message": "Hey I sent a message"
}'

Or 
curl -X 'POST' \
  'http://localhost:8000/api/account/send_push_notification' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc1NzkyODAsImV4cCI6MTc4NzY2NTY4MH0.vz0J9B6WvMA-We-E8pNamP2SsWIrLLzlGE3K4taN_VI' \
  -H 'Content-Type: application/json' \
  -d '{
  "user_id": "user_id",
  "notification_type": "ping",
}'