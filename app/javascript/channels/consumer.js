import { createConsumer } from "@rails/actioncable"

console.log("=== CONSUMER.JS LOADED ===")

const consumer = createConsumer()

console.log("=== ACTION CABLE CONSUMER CREATED ===")
console.log("Consumer:", consumer)
console.log("WebSocket URL:", consumer.url)

// Add event listeners for debugging using ActionCable's event system
if (consumer.connection) {
    console.log("=== ADDING CONNECTION EVENT LISTENERS ===")

    // ActionCable uses a different event system - we need to access the monitor
    const connection = consumer.connection

    // Override connection methods to add logging
    const originalOpen = connection.open
    const originalClose = connection.close

    connection.open = function() {
        console.log("🟢 Action Cable CONNECTING...")
        return originalOpen.apply(this, arguments)
    }

    connection.close = function() {
        console.log("🔴 Action Cable DISCONNECTING...")
        return originalClose.apply(this, arguments)
    }

    // Listen to the connection monitor events
    if (connection.monitor) {
        const originalRecordConnect = connection.monitor.recordConnect
        const originalRecordDisconnect = connection.monitor.recordDisconnect

        connection.monitor.recordConnect = function() {
            console.log("🟢 Action Cable CONNECTED!")
            return originalRecordConnect.apply(this, arguments)
        }

        connection.monitor.recordDisconnect = function() {
            console.log("🔴 Action Cable DISCONNECTED!")
            return originalRecordDisconnect.apply(this, arguments)
        }
    }
} else {
    console.log("❌ NO CONNECTION OBJECT FOUND")
}

export default consumer