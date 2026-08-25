curl -X 'POST' \
  'http://localhost:8000/api/account/change-password' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc1NzkyODAsImV4cCI6MTc4NzY2NTY4MH0.vz0J9B6WvMA-We-E8pNamP2SsWIrLLzlGE3K4taN_VI' \
  -H 'Content-Type: application/json' \
  -d '{
  "encrypted_blob": "Azino_#",
  "current_password": "Azino@123",
  "new_password": "Azino@1234"
}'

