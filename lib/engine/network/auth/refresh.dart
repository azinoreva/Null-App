curl -X 'POST' \
  'http://localhost:8000/api/refresh' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc0Nzc1NzAsImV4cCI6MTc4ODA4MjM3MCwidHlwZSI6InJlZnJlc2hfdG9rZW4ifQ.amb6EjUUfc0U1tx94bXLR19_1hEqubywA6TD5W6BjCk' \
  -d ''


  Response: 
  {
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc1NzkyODAsImV4cCI6MTc4NzY2NTY4MH0.vz0J9B6WvMA-We-E8pNamP2SsWIrLLzlGE3K4taN_VI",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc1NzkyODAsImV4cCI6MTc4ODE4NDA4MCwidHlwZSI6InJlZnJlc2hfdG9rZW4ifQ.7xE5gnf-J4PSUVXjPK3sbXx89cOzMQAyJeyDevSsIvI",
  "expires": 86400
}