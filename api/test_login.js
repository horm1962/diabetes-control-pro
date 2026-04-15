const http = require('http');

const data = JSON.stringify({
  email: 'test@test.com',
  password: 'wrongpassword'
});

const options = {
  hostname: '127.0.0.1', // Or 'localhost'
  port: 3000,
  path: '/auth/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

const req = http.request(options, res => {
  console.log(`statusCode: ${res.statusCode}`);
  let responseBody = '';

  res.on('data', d => {
    responseBody += d;
  });

  res.on('end', () => {
    console.log(`response: ${responseBody}`);
  });
});

req.on('error', error => {
  console.error(error);
});

req.write(data);
req.end();
