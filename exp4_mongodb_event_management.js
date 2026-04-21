// ============================================================
// Experiment 4: Create a MongoDB Database for an
// Event Management System
// ============================================================

// -------------------------
// CREATE DATABASE & COLLECTIONS
// -------------------------
use EventManagementDB;

db.createCollection("events");
db.createCollection("organizers");
db.createCollection("attendees");
db.createCollection("venues");

// -------------------------
// INSERT SAMPLE DATA
// -------------------------

// Events
db.events.insertOne({
    eventName : "Tech Conference",
    date      : ISODate("2024-04-15"),
    organizer : "Tech Events LLC",
    venue     : "Conference Center A",
    attendees : ["Alice", "Bob", "Charlie"]
});

db.events.insertOne({
    eventName : "Hackathon 2024",
    date      : ISODate("2024-05-18"),
    organizer : "Dev Club",
    venue     : "Chennai, India",
    attendees : ["Dave", "Eva"]
});

// Organizers
db.organizers.insertOne({
    organizerName  : "Music Festivals Inc",
    contactPerson  : "Emily Adams",
    eventsOrganized: ["Music Festival", "Summer Concert"]
});

// Attendees
db.attendees.insertOne({
    attendeeName   : "Charlie",
    eventsAttended : ["Tech Conference", "Music Festival"]
});

db.attendees.insertOne({
    attendeeName   : "Bob",
    eventsAttended : ["Tech Conference"]
});

// Venues
db.venues.insertOne({
    venueName    : "Exhibition Hall",
    capacity     : 500,
    eventsHosted : ["Art Exhibition", "Business Expo"]
});

// -------------------------
// QUERY DATA
// -------------------------

// Retrieve all events
db.events.find({});

// Find events on a specific date
db.events.find({ date: ISODate("2024-04-15") });

// Find events after a specific date
db.events.find({ date: { $gt: ISODate("2024-02-29") } });

// Find events by name
db.events.find({ eventName: "Hackathon 2024" });

// List all organizers
db.organizers.find({});

// Find attendees for a specific event
db.attendees.find({ eventsAttended: "Tech Conference" });

// Find users by email (users collection example)
// db.users.find({ email: "user@example.com" });

// List all venues
db.venues.find({});

// -------------------------
// UPDATE DATA
// -------------------------

// Update event venue
db.events.updateOne(
    { eventName: "Tech Conference" },
    { $set: { venue: "Conference Center B" } }
);

// Add a new attendee to an event
db.events.updateOne(
    { eventName: "Tech Conference" },
    { $push: { attendees: "Frank" } }
);

// -------------------------
// DELETE DATA
// -------------------------

// Delete an attendee record
db.attendees.deleteOne({ attendeeName: "Bob" });

// Delete events before a certain date
db.events.deleteMany({ date: { $lt: ISODate("2024-01-01") } });
