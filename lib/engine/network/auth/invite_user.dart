curl -X 'POST' \
  'http://127.0.0.1:8000/api/invite-user' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc0Nzc1NzAsImV4cCI6MTc4NzU2Mzk3MH0.9hp4DZYaiQ-nWgPva7L_zfzpLmTmwRcuaJFN19EPdn4' \
  -d ''



  Response:

  {
  "invitation_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiY2YwMGEwYjctNzAzMi00YWQ5LTlhNTYtZDEwOGQwZmE2ZDhhIiwiaWF0IjoxNzg3NDgxMjU3LCJleHAiOjE3ODc0ODI0NTd9.Q3F5mf-mJ7hLYvoMWERSdc1M5gbNydYz6EfRK9tt8Rg",
  "inviter_user_id": "5eeba611-8d78-4886-90ee-e4ac6928984d",
  "expiration": 1200
}