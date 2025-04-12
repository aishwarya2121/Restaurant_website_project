const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(express.static('.')); // Serve static files from current directory

// File path for storing bookings
const bookingsFile = path.join(__dirname, 'bookings.json');

// Initialize bookings file if it doesn't exist
if (!fs.existsSync(bookingsFile)) {
    fs.writeFileSync(bookingsFile, JSON.stringify([]));
}

// API Endpoints
app.post('/api/bookings', (req, res) => {
    try {
        const bookings = JSON.parse(fs.readFileSync(bookingsFile, 'utf8'));
        const newBooking = {
            ...req.body,
            id: Date.now(), // Simple unique ID
            bookingDate: new Date().toISOString()
        };
        
        bookings.push(newBooking);
        fs.writeFileSync(bookingsFile, JSON.stringify(bookings, null, 2));
        
        res.status(201).json({ message: 'Booking created successfully' });
    } catch (err) {
        console.error('Error creating booking:', err);
        res.status(500).json({ error: 'Failed to create booking' });
    }
});

app.get('/api/bookings', (req, res) => {
    try {
        const bookings = JSON.parse(fs.readFileSync(bookingsFile, 'utf8'));
        res.json(bookings);
    } catch (err) {
        console.error('Error fetching bookings:', err);
        res.status(500).json({ error: 'Failed to fetch bookings' });
    }
});

// Start server
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
}); 