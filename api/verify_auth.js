const axios = require('axios');

async function test() {
  try {
    console.log('Testing Login...');
    const loginRes = await axios.post('http://127.0.0.1:3000/auth/login', {
      email: 'test@example.com',
      password: 'Password123'
    });
    
    const token = loginRes.data.access_token;
    console.log('Login Success! Token starting with:', token.substring(0, 20));
    
    console.log('Testing Profile Fetch with Token...');
    const profileRes = await axios.get('http://127.0.0.1:3000/users/profile', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    console.log('Profile Fetch Success! Profile ID:', profileRes.data.id);
    console.log('TEST PASSED: Token is valid and working.');
  } catch (error) {
    console.error('TEST FAILED');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', JSON.stringify(error.response.data));
    } else {
      console.error('Error:', error.message);
    }
  }
}

test();
