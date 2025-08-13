import consumer from "channels/consumer"

consumer.subscriptions.create("UserStatsChannel", {
    connected() {
        console.log("Connected to UserStatsChannel")
    },

    disconnected() {
        console.log("Disconnected from UserStatsChannel")
    },

    received(data) {
        console.log("Received data:", data)

        if (data.type === 'projects_stats_update') {
            // Get the projects stats frame
            const projectsFrame = document.getElementById('projects_stats')
            console.log("ACTION CABLE MESSAGE RECEIVED:", data);
            if (projectsFrame && data.html) {
                // Replace the entire turbo frame content with the new HTML
                projectsFrame.outerHTML = data.html
                console.log("Updated projects stats frame")
            } else {
                console.log("Projects frame not found or no HTML data")
            }
        }
    }
})