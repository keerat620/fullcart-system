const CONFIG = {
    API_BASE: window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1' 
        ? 'http://localhost:8000/api' 
        : 'https://fullcart-backend.onrender.com/api'
};
