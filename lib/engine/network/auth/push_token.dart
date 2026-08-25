curl -X 'POST' \
  'http://127.0.0.1:8000/api/account/push-notification-token' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc0Nzc1NzAsImV4cCI6MTc4NzU2Mzk3MH0.9hp4DZYaiQ-nWgPva7L_zfzpLmTmwRcuaJFN19EPdn4' \
  -H 'Content-Type: application/json' \
  -d '{
  "token": "FCMTOKEN#@%%#"
}'


Response:

{
  "status": "success",
  "message": "Push notification token updated successfully."
}