import Foundation

struct ExampleShortcut: Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let category: ShortcutCategory
    let icon: String
    let colorHex: String
    let actions: [TemplateAction]
}

struct TemplateAction: Hashable {
    let identifier: String
    let displayName: String
    let parameters: [String: String]
}

// 118 ready-made example shortcuts. Each maps to real Shortcuts actions
// when the user taps "Add to Shortcuts" — the file builder constructs a
// signed-style .shortcut plist from the templates below.
enum ExampleShortcuts {
    static let all: [ExampleShortcut] = driving + focus + family + work + health + smartHome + travel + productivity + creative + wellness

    static func filtered(by category: ShortcutCategory) -> [ExampleShortcut] {
        all.filter { $0.category == category }
    }

    // MARK: - Driving
    static let driving: [ExampleShortcut] = [
        .init(id: "drv_home", title: "Drive Home", summary: "Sets DND, opens Maps to home, plays your driving playlist.",
              category: .driving, icon: "house.and.flag.fill", colorHex: "#1E88E5",
              actions: [
                .init(identifier: "is.workflow.actions.dnd.set", displayName: "Turn On Do Not Disturb", parameters: ["state": "on"]),
                .init(identifier: "is.workflow.actions.url", displayName: "Open Maps to Home", parameters: ["url": "maps://?daddr=Home"]),
                .init(identifier: "is.workflow.actions.playmusic", displayName: "Play Driving Playlist", parameters: ["playlist": "Driving"])
              ]),
        .init(id: "drv_work", title: "Drive to Work", summary: "Reads commute traffic, starts navigation, queues news podcast.",
              category: .driving, icon: "briefcase.fill", colorHex: "#3949AB",
              actions: [
                .init(identifier: "is.workflow.actions.weather.gettraffic", displayName: "Get Traffic Conditions", parameters: [:]),
                .init(identifier: "is.workflow.actions.url", displayName: "Open Maps to Work", parameters: ["url": "maps://?daddr=Work"]),
                .init(identifier: "is.workflow.actions.playpodcast", displayName: "Play Latest Podcast", parameters: [:])
              ]),
        .init(id: "drv_roadtrip", title: "Road Trip Mode", summary: "Long-drive playlist, low power, GPS check-in.",
              category: .driving, icon: "map.fill", colorHex: "#1976D2",
              actions: [
                .init(identifier: "is.workflow.actions.lowpowermode.set", displayName: "Low Power On", parameters: ["state": "on"]),
                .init(identifier: "is.workflow.actions.playmusic", displayName: "Play Road Trip Playlist", parameters: ["playlist": "Road Trip"])
              ]),
        .init(id: "drv_findcar", title: "Find Parked Car", summary: "Drops a Maps pin where you parked.", category: .driving, icon: "mappin.and.ellipse", colorHex: "#0277BD",
              actions: [.init(identifier: "is.workflow.actions.location.current", displayName: "Save Current Location", parameters: [:])]),
        .init(id: "drv_gas", title: "Gas Station Near Me", summary: "Searches Maps for nearest gas station.", category: .driving, icon: "fuelpump.fill", colorHex: "#01579B",
              actions: [.init(identifier: "is.workflow.actions.searchlocally", displayName: "Search Maps", parameters: ["query": "gas station"])]),
        .init(id: "drv_ev", title: "EV Charger Finder", summary: "Locates the closest EV charging station.", category: .driving, icon: "bolt.car.fill", colorHex: "#0288D1",
              actions: [.init(identifier: "is.workflow.actions.searchlocally", displayName: "Search Maps", parameters: ["query": "EV charging"])]),
        .init(id: "drv_eta", title: "Send ETA", summary: "Texts your ETA to a contact.", category: .driving, icon: "paperplane.fill", colorHex: "#039BE5",
              actions: [.init(identifier: "is.workflow.actions.sendmessage", displayName: "Send Message", parameters: ["body": "On my way! ETA shortly."])]),
        .init(id: "drv_call", title: "Hands-Free Call", summary: "Voice-launches a favorite contact.", category: .driving, icon: "phone.fill", colorHex: "#0288D1",
              actions: [.init(identifier: "is.workflow.actions.callcontact", displayName: "Call Contact", parameters: [:])]),
        .init(id: "drv_log", title: "Trip Log", summary: "Logs the start of a drive for mileage tracking.", category: .driving, icon: "calendar.badge.clock", colorHex: "#0277BD",
              actions: [.init(identifier: "is.workflow.actions.appendnote", displayName: "Append Trip Note", parameters: ["note": "Trip start: \(Date())"])]),
        .init(id: "drv_safe", title: "Drive Safe Auto-Reply", summary: "Auto-replies to texts while driving.", category: .driving, icon: "shield.fill", colorHex: "#01579B",
              actions: [.init(identifier: "is.workflow.actions.dnd.set", displayName: "Driving DND", parameters: ["state": "driving"])]),
        .init(id: "drv_audiobook", title: "Resume Audiobook", summary: "Picks up your current Audible/Books title.", category: .driving, icon: "book.closed.fill", colorHex: "#1565C0",
              actions: [.init(identifier: "is.workflow.actions.playmusic", displayName: "Resume Audiobook", parameters: [:])]),
        .init(id: "drv_carplay", title: "CarPlay Setup", summary: "Optimizes screen + audio when CarPlay connects.", category: .driving, icon: "car.2.fill", colorHex: "#1976D2",
              actions: [.init(identifier: "is.workflow.actions.brightness.set", displayName: "Set Brightness", parameters: ["level": "0.7"])]),
        .init(id: "drv_speed", title: "Speed Limit Check", summary: "Shows the current road's speed limit.", category: .driving, icon: "speedometer", colorHex: "#0D47A1",
              actions: [.init(identifier: "is.workflow.actions.url", displayName: "Open Maps", parameters: ["url": "maps://"])]),
        .init(id: "drv_rest", title: "Rest Stop Finder", summary: "Finds the next rest stop on your route.", category: .driving, icon: "fork.knife", colorHex: "#1565C0",
              actions: [.init(identifier: "is.workflow.actions.searchlocally", displayName: "Search Rest Stops", parameters: ["query": "rest stop"])]),
        .init(id: "drv_voice", title: "Dashcam Voice Note", summary: "Quickly records a hands-free voice memo.", category: .driving, icon: "mic.fill", colorHex: "#1E88E5",
              actions: [.init(identifier: "is.workflow.actions.recordaudio", displayName: "Record Audio", parameters: [:])])
    ]

    // MARK: - Focus
    static let focus: [ExampleShortcut] = [
        .init(id: "fcs_pomo", title: "Deep Work 25", summary: "25-minute Pomodoro with DND + brown noise.", category: .focus, icon: "timer", colorHex: "#5E35B1",
              actions: [
                .init(identifier: "is.workflow.actions.dnd.set", displayName: "Focus On", parameters: ["state": "on"]),
                .init(identifier: "is.workflow.actions.timer.start", displayName: "Start 25min Timer", parameters: ["minutes": "25"])
              ]),
        .init(id: "fcs_block", title: "Block Distractions", summary: "Locks distracting apps via Screen Time.", category: .focus, icon: "lock.shield.fill", colorHex: "#673AB7",
              actions: [.init(identifier: "is.workflow.actions.screen.time.toggle", displayName: "Screen Time On", parameters: ["state": "on"])]),
        .init(id: "fcs_meeting", title: "Meeting Mode", summary: "Mutes notifications, dims display, opens calendar.", category: .focus, icon: "person.2.wave.2.fill", colorHex: "#4527A0",
              actions: [.init(identifier: "is.workflow.actions.dnd.set", displayName: "Meeting DND", parameters: ["state": "on"])]),
        .init(id: "fcs_read", title: "Reading Time", summary: "Warm display, DND, opens Books.", category: .focus, icon: "book.fill", colorHex: "#311B92",
              actions: [.init(identifier: "is.workflow.actions.url", displayName: "Open Books", parameters: ["url": "ibooks://"])]),
        .init(id: "fcs_study", title: "Study Session", summary: "60-minute deep focus block with white noise.", category: .focus, icon: "graduationcap.fill", colorHex: "#5E35B1",
              actions: [.init(identifier: "is.workflow.actions.timer.start", displayName: "Start 60min Timer", parameters: ["minutes": "60"])]),
        .init(id: "fcs_code", title: "Code Mode", summary: "Opens IDE, blocks Slack, plays focus playlist.", category: .focus, icon: "chevron.left.forwardslash.chevron.right", colorHex: "#7E57C2",
              actions: [.init(identifier: "is.workflow.actions.playmusic", displayName: "Play Focus Music", parameters: ["playlist": "Focus"])]),
        .init(id: "fcs_write", title: "Writing Sprint", summary: "30-minute sprint with hemingway-style focus.", category: .focus, icon: "pencil.and.outline", colorHex: "#9575CD",
              actions: [.init(identifier: "is.workflow.actions.timer.start", displayName: "Start 30min Timer", parameters: ["minutes": "30"])]),
        .init(id: "fcs_white", title: "White Noise + DND", summary: "Plays white noise loop, mutes notifications.", category: .focus, icon: "waveform", colorHex: "#7E57C2",
              actions: [.init(identifier: "is.workflow.actions.playmusic", displayName: "White Noise", parameters: ["playlist": "White Noise"])]),
        .init(id: "fcs_coffee", title: "Coffee Shop Ambience", summary: "Plays cafe ambience for working from home.", category: .focus, icon: "cup.and.saucer.fill", colorHex: "#673AB7",
              actions: [.init(identifier: "is.workflow.actions.playmusic", displayName: "Cafe Ambience", parameters: ["playlist": "Cafe"])]),
        .init(id: "fcs_forest", title: "Forest Sounds", summary: "Forest ambience for relaxed deep work.", category: .focus, icon: "tree.fill", colorHex: "#512DA8",
              actions: [.init(identifier: "is.workflow.actions.playmusic", displayName: "Forest Sounds", parameters: ["playlist": "Forest"])]),
        .init(id: "fcs_brown", title: "Brown Noise Loop", summary: "Loops brown noise indefinitely.", category: .focus, icon: "speaker.wave.3.fill", colorHex: "#7E57C2",
              actions: [.init(identifier: "is.workflow.actions.playmusic", displayName: "Brown Noise", parameters: ["playlist": "Brown Noise"])]),
        .init(id: "fcs_mute1", title: "Mute Notifications 1hr", summary: "Silences your phone for 1 hour.", category: .focus, icon: "bell.slash.fill", colorHex: "#5E35B1",
              actions: [.init(identifier: "is.workflow.actions.dnd.set", displayName: "DND 1hr", parameters: ["duration": "60"])]),
        .init(id: "fcs_end", title: "End Focus Session", summary: "Wraps up: turns DND off, logs notes.", category: .focus, icon: "flag.checkered", colorHex: "#673AB7",
              actions: [.init(identifier: "is.workflow.actions.dnd.set", displayName: "DND Off", parameters: ["state": "off"])]),
        .init(id: "fcs_standup", title: "Daily Standup Prep", summary: "Pulls yesterday's notes + today's calendar.", category: .focus, icon: "list.bullet.rectangle.fill", colorHex: "#4527A0",
              actions: [.init(identifier: "is.workflow.actions.calendar.todayevents", displayName: "Today's Events", parameters: [:])]),
        .init(id: "fcs_email15", title: "Email Triage 15min", summary: "Timed inbox cleanup with auto-end.", category: .focus, icon: "envelope.badge.fill", colorHex: "#9575CD",
              actions: [.init(identifier: "is.workflow.actions.timer.start", displayName: "15min Timer", parameters: ["minutes": "15"])])
    ]

    // MARK: - Family
    static let family: [ExampleShortcut] = [
        .init(id: "fam_callmom", title: "Call Mom", summary: "One-tap call to a favorite contact.", category: .family, icon: "phone.circle.fill", colorHex: "#EC407A",
              actions: [.init(identifier: "is.workflow.actions.callcontact", displayName: "Call Mom", parameters: ["contact": "Mom"])]),
        .init(id: "fam_group", title: "Family Group Text", summary: "Sends a quick check-in text to family group.", category: .family, icon: "bubble.left.and.bubble.right.fill", colorHex: "#E91E63",
              actions: [.init(identifier: "is.workflow.actions.sendmessage", displayName: "Group Text", parameters: ["body": "Hey, checking in!"])]),
        .init(id: "fam_movie", title: "Movie Night Mode", summary: "Lights down, AppleTV on, DND on.", category: .family, icon: "tv.fill", colorHex: "#D81B60",
              actions: [.init(identifier: "is.workflow.actions.home.scene", displayName: "Movie Scene", parameters: ["scene": "Movie Night"])]),
        .init(id: "fam_baby", title: "Babysitter ETA", summary: "Texts the sitter your ETA home.", category: .family, icon: "figure.and.child.holdinghands", colorHex: "#F06292",
              actions: [.init(identifier: "is.workflow.actions.sendmessage", displayName: "ETA", parameters: ["body": "Home in 20 min!"])]),
        .init(id: "fam_bedtime", title: "Kids Bedtime", summary: "Dims lights, plays lullaby playlist.", category: .family, icon: "moon.stars.fill", colorHex: "#AD1457",
              actions: [.init(identifier: "is.workflow.actions.playmusic", displayName: "Lullaby", parameters: ["playlist": "Lullabies"])]),
        .init(id: "fam_loc", title: "Share Family Location", summary: "Shares your live location with family.", category: .family, icon: "location.fill", colorHex: "#EC407A",
              actions: [.init(identifier: "is.workflow.actions.location.share", displayName: "Share Location", parameters: [:])]),
        .init(id: "fam_bday", title: "Birthday Reminder", summary: "Reminds you 1 day before family birthdays.", category: .family, icon: "gift.fill", colorHex: "#E91E63",
              actions: [.init(identifier: "is.workflow.actions.reminders.add", displayName: "Add Reminder", parameters: [:])]),
        .init(id: "fam_dinner", title: "Dinner Together", summary: "Calls everyone to dinner via HomePod.", category: .family, icon: "fork.knife.circle.fill", colorHex: "#D81B60",
              actions: [.init(identifier: "is.workflow.actions.home.intercom", displayName: "Intercom", parameters: ["message": "Dinner is ready!"])]),
        .init(id: "fam_poll", title: "Weekend Plan Poll", summary: "Sends a quick poll to family group.", category: .family, icon: "questionmark.bubble.fill", colorHex: "#F06292",
              actions: [.init(identifier: "is.workflow.actions.sendmessage", displayName: "Send Poll", parameters: ["body": "What should we do this weekend?"])]),
        .init(id: "fam_photo", title: "Photo of the Day", summary: "Picks today's best photo, shares to family.", category: .family, icon: "photo.fill.on.rectangle.fill", colorHex: "#AD1457",
              actions: [.init(identifier: "is.workflow.actions.photos.latest", displayName: "Latest Photo", parameters: [:])])
    ]

    // MARK: - Work
    static let work: [ExampleShortcut] = [
        .init(id: "wrk_start", title: "Start Workday", summary: "Calendar, Slack, music, focus mode.", category: .work, icon: "sunrise.fill", colorHex: "#FB8C00",
              actions: [.init(identifier: "is.workflow.actions.dnd.set", displayName: "Work Focus", parameters: ["state": "work"])]),
        .init(id: "wrk_end", title: "End of Day Summary", summary: "Logs the day, closes tabs, sets EOD note.", category: .work, icon: "sunset.fill", colorHex: "#F57C00",
              actions: [.init(identifier: "is.workflow.actions.appendnote", displayName: "Append EOD Note", parameters: ["note": "EOD: "])]),
        .init(id: "wrk_standup", title: "Standup Notes", summary: "Builds a 3-bullet standup from yesterday's items.", category: .work, icon: "list.bullet.rectangle", colorHex: "#EF6C00",
              actions: [.init(identifier: "is.workflow.actions.notes.create", displayName: "New Note", parameters: [:])]),
        .init(id: "wrk_email", title: "Quick Email Draft", summary: "Drafts an email with current clipboard text.", category: .work, icon: "envelope.fill", colorHex: "#E65100",
              actions: [.init(identifier: "is.workflow.actions.mail.compose", displayName: "Compose Email", parameters: [:])]),
        .init(id: "wrk_slack", title: "Send Slack Status", summary: "Updates Slack status to current activity.", category: .work, icon: "bubble.left.fill", colorHex: "#F57C00",
              actions: [.init(identifier: "is.workflow.actions.url", displayName: "Open Slack", parameters: ["url": "slack://"])]),
        .init(id: "wrk_recap", title: "Meeting Recap", summary: "Records meeting + transcribes to notes.", category: .work, icon: "doc.text.fill", colorHex: "#FB8C00",
              actions: [.init(identifier: "is.workflow.actions.recordaudio", displayName: "Record Audio", parameters: [:])]),
        .init(id: "wrk_proj", title: "New Project Folder", summary: "Creates iCloud folder + Notes file for new project.", category: .work, icon: "folder.fill.badge.plus", colorHex: "#FF9800",
              actions: [.init(identifier: "is.workflow.actions.file.createfolder", displayName: "Create Folder", parameters: [:])]),
        .init(id: "wrk_review", title: "Daily Tasks Review", summary: "Lists today's reminders + open tasks.", category: .work, icon: "checklist", colorHex: "#FFA726",
              actions: [.init(identifier: "is.workflow.actions.reminders.list", displayName: "List Reminders", parameters: [:])]),
        .init(id: "wrk_track", title: "Time Tracker Start", summary: "Starts a Toggl/Clockify timer.", category: .work, icon: "stopwatch.fill", colorHex: "#FB8C00",
              actions: [.init(identifier: "is.workflow.actions.url", displayName: "Open Toggl", parameters: ["url": "toggl://"])]),
        .init(id: "wrk_block", title: "Calendar Block 1hr", summary: "Auto-creates a focus block on your calendar.", category: .work, icon: "calendar.badge.plus", colorHex: "#F57C00",
              actions: [.init(identifier: "is.workflow.actions.calendar.add", displayName: "Add Event", parameters: ["duration": "60"])]),
        .init(id: "wrk_ooo", title: "Out of Office Auto", summary: "Sets OOO replies + DND for vacation.", category: .work, icon: "airplane.circle.fill", colorHex: "#EF6C00",
              actions: [.init(identifier: "is.workflow.actions.dnd.set", displayName: "Vacation DND", parameters: ["state": "on"])]),
        .init(id: "wrk_tomorrow", title: "Tomorrow's Schedule", summary: "Reads tomorrow's calendar aloud.", category: .work, icon: "calendar.day.timeline.left", colorHex: "#E65100",
              actions: [.init(identifier: "is.workflow.actions.calendar.events", displayName: "Tomorrow Events", parameters: ["day": "tomorrow"])]),
        .init(id: "wrk_inbox0", title: "Email Inbox Zero", summary: "Triages inbox: archive, snooze, reply.", category: .work, icon: "tray.full.fill", colorHex: "#FB8C00",
              actions: [.init(identifier: "is.workflow.actions.mail.inbox", displayName: "Open Mail", parameters: [:])]),
        .init(id: "wrk_invoice", title: "Quick Invoice Draft", summary: "Templated invoice in Pages or Numbers.", category: .work, icon: "doc.text.below.ecg.fill", colorHex: "#FF9800",
              actions: [.init(identifier: "is.workflow.actions.url", displayName: "Open Numbers", parameters: ["url": "numbers://"])]),
        .init(id: "wrk_calendly", title: "Send Calendly Link", summary: "Copies + shares your booking link.", category: .work, icon: "link.circle.fill", colorHex: "#FFA726",
              actions: [.init(identifier: "is.workflow.actions.clipboard.set", displayName: "Copy Link", parameters: ["text": "https://calendly.com/me"])])
    ]

    // MARK: - Health
    static let health: [ExampleShortcut] = [
        .init(id: "hth_morning", title: "Morning Routine", summary: "Weather, news, water reminder, light stretch.", category: .health, icon: "sun.max.fill", colorHex: "#E53935",
              actions: [.init(identifier: "is.workflow.actions.weather.current", displayName: "Get Weather", parameters: [:])]),
        .init(id: "hth_evening", title: "Evening Wind Down", summary: "Dim lights, sleep playlist, charge phone.", category: .health, icon: "moon.fill", colorHex: "#C62828",
              actions: [.init(identifier: "is.workflow.actions.home.scene", displayName: "Wind Down", parameters: ["scene": "Wind Down"])]),
        .init(id: "hth_workout", title: "Workout Start", summary: "Starts workout, plays gym playlist.", category: .health, icon: "figure.run", colorHex: "#D32F2F",
              actions: [.init(identifier: "is.workflow.actions.workout.start", displayName: "Start Workout", parameters: [:])]),
        .init(id: "hth_water", title: "Hydration Reminder", summary: "Reminds you to drink water every 90 min.", category: .health, icon: "drop.fill", colorHex: "#EF5350",
              actions: [.init(identifier: "is.workflow.actions.reminders.add", displayName: "Drink Water", parameters: [:])]),
        .init(id: "hth_steps", title: "Step Goal Check", summary: "Reads today's steps progress.", category: .health, icon: "figure.walk", colorHex: "#E53935",
              actions: [.init(identifier: "is.workflow.actions.health.steps", displayName: "Get Steps", parameters: [:])]),
        .init(id: "hth_med", title: "Meditate 5min", summary: "5-minute mindful breathing session.", category: .health, icon: "leaf.fill", colorHex: "#C62828",
              actions: [.init(identifier: "is.workflow.actions.timer.start", displayName: "5min Timer", parameters: ["minutes": "5"])]),
        .init(id: "hth_sleep", title: "Sleep Mode", summary: "Activates sleep focus + winds down notifications.", category: .health, icon: "bed.double.fill", colorHex: "#B71C1C",
              actions: [.init(identifier: "is.workflow.actions.dnd.set", displayName: "Sleep Focus", parameters: ["state": "sleep"])]),
        .init(id: "hth_stand", title: "Standing Desk", summary: "Toggle a smart standing desk via HomeKit.", category: .health, icon: "rectangle.stack.fill", colorHex: "#D32F2F",
              actions: [.init(identifier: "is.workflow.actions.home.toggle", displayName: "Toggle Desk", parameters: ["device": "Standing Desk"])]),
        .init(id: "hth_stretch", title: "Stretch Reminder", summary: "Hourly stretch nudges during work hours.", category: .health, icon: "figure.cooldown", colorHex: "#EF5350",
              actions: [.init(identifier: "is.workflow.actions.reminders.add", displayName: "Stretch", parameters: [:])]),
        .init(id: "hth_hr", title: "Heart Rate Snapshot", summary: "Reads your latest heart rate from Health.", category: .health, icon: "heart.text.square.fill", colorHex: "#E53935",
              actions: [.init(identifier: "is.workflow.actions.health.heartrate", displayName: "Heart Rate", parameters: [:])]),
        .init(id: "hth_period", title: "Cycle Log", summary: "Quick log into Health cycle tracking.", category: .health, icon: "calendar.circle.fill", colorHex: "#C62828",
              actions: [.init(identifier: "is.workflow.actions.health.log", displayName: "Log Cycle", parameters: [:])]),
        .init(id: "hth_mood", title: "Mood Check-in", summary: "Logs your mood to Health daily.", category: .health, icon: "face.smiling.inverse", colorHex: "#D32F2F",
              actions: [.init(identifier: "is.workflow.actions.health.mood", displayName: "Log Mood", parameters: [:])]),
        .init(id: "hth_breath", title: "Mindful Breathing", summary: "Box-breathing 4-4-4-4 for 2 minutes.", category: .health, icon: "wind", colorHex: "#EF5350",
              actions: [.init(identifier: "is.workflow.actions.timer.start", displayName: "2min Timer", parameters: ["minutes": "2"])]),
        .init(id: "hth_sunrise", title: "Sunrise Yoga", summary: "Yoga playlist + sunrise lighting scene.", category: .health, icon: "figure.mind.and.body", colorHex: "#E57373",
              actions: [.init(identifier: "is.workflow.actions.playmusic", displayName: "Yoga Playlist", parameters: ["playlist": "Yoga"])]),
        .init(id: "hth_recovery", title: "Recovery Day", summary: "Active rest reminders + foam roll timer.", category: .health, icon: "battery.100.bolt", colorHex: "#B71C1C",
              actions: [.init(identifier: "is.workflow.actions.reminders.add", displayName: "Foam Roll", parameters: [:])])
    ]

    // MARK: - Smart Home
    static let smartHome: [ExampleShortcut] = [
        .init(id: "sh_imhome", title: "I'm Home", summary: "Lights on, thermostat to comfort, music on.", category: .smartHome, icon: "house.lodge.fill", colorHex: "#00897B",
              actions: [.init(identifier: "is.workflow.actions.home.scene", displayName: "Arrive Home", parameters: ["scene": "Arrive"])]),
        .init(id: "sh_goodnight", title: "Goodnight", summary: "All off, doors locked, alarm armed.", category: .smartHome, icon: "moon.zzz.fill", colorHex: "#00695C",
              actions: [.init(identifier: "is.workflow.actions.home.scene", displayName: "Goodnight", parameters: ["scene": "Goodnight"])]),
        .init(id: "sh_movie", title: "Movie Time", summary: "TV on, lights dim, blackout shades down.", category: .smartHome, icon: "popcorn.fill", colorHex: "#00796B",
              actions: [.init(identifier: "is.workflow.actions.home.scene", displayName: "Movie", parameters: ["scene": "Movie"])]),
        .init(id: "sh_wake", title: "Wake Up Lights", summary: "Slow sunrise lighting + soft music.", category: .smartHome, icon: "sunrise.circle.fill", colorHex: "#26A69A",
              actions: [.init(identifier: "is.workflow.actions.home.scene", displayName: "Sunrise", parameters: ["scene": "Sunrise"])]),
        .init(id: "sh_away", title: "Away From Home", summary: "Eco mode, lights off, security on.", category: .smartHome, icon: "shield.lefthalf.filled", colorHex: "#004D40",
              actions: [.init(identifier: "is.workflow.actions.home.scene", displayName: "Away", parameters: ["scene": "Away"])]),
        .init(id: "sh_cook", title: "Cooking Mode", summary: "Bright kitchen lights + cooking playlist.", category: .smartHome, icon: "fork.knife.circle.fill", colorHex: "#00897B",
              actions: [.init(identifier: "is.workflow.actions.home.scene", displayName: "Cook", parameters: ["scene": "Cooking"])]),
        .init(id: "sh_dinner", title: "Dinner Lights", summary: "Warm dining-room scene.", category: .smartHome, icon: "lightbulb.fill", colorHex: "#26A69A",
              actions: [.init(identifier: "is.workflow.actions.home.scene", displayName: "Dinner", parameters: ["scene": "Dinner"])]),
        .init(id: "sh_vacuum", title: "Run Vacuum", summary: "Starts your robot vacuum.", category: .smartHome, icon: "rectangle.3.offgrid.fill", colorHex: "#00695C",
              actions: [.init(identifier: "is.workflow.actions.home.toggle", displayName: "Start Vacuum", parameters: ["device": "Vacuum"])]),
        .init(id: "sh_garage", title: "Garage Closed?", summary: "Reads garage door status aloud.", category: .smartHome, icon: "door.garage.closed", colorHex: "#00796B",
              actions: [.init(identifier: "is.workflow.actions.home.status", displayName: "Garage Status", parameters: ["device": "Garage"])]),
        .init(id: "sh_door", title: "Front Door Camera", summary: "Opens front door camera live feed.", category: .smartHome, icon: "video.fill", colorHex: "#00897B",
              actions: [.init(identifier: "is.workflow.actions.home.camera", displayName: "Front Door Cam", parameters: ["device": "Front Door"])])
    ]

    // MARK: - Travel
    static let travel: [ExampleShortcut] = [
        .init(id: "trv_flight", title: "Flight Mode", summary: "Airplane on, save boarding pass to wallet.", category: .travel, icon: "airplane", colorHex: "#0097A7",
              actions: [.init(identifier: "is.workflow.actions.airplane.set", displayName: "Airplane Mode", parameters: ["state": "on"])]),
        .init(id: "trv_hotel", title: "Hotel Check-in", summary: "Saves confirmation, sets local time.", category: .travel, icon: "bed.double.circle.fill", colorHex: "#00838F",
              actions: [.init(identifier: "is.workflow.actions.appendnote", displayName: "Save Confirmation", parameters: [:])]),
        .init(id: "trv_currency", title: "Currency Convert", summary: "Quick FX with current rate.", category: .travel, icon: "dollarsign.circle.fill", colorHex: "#0097A7",
              actions: [.init(identifier: "is.workflow.actions.url", displayName: "Open FX", parameters: ["url": "https://wise.com"])]),
        .init(id: "trv_translate", title: "Translate Phrase", summary: "Translates a phrase via Apple Translate.", category: .travel, icon: "character.bubble.fill", colorHex: "#006064",
              actions: [.init(identifier: "is.workflow.actions.translate.text", displayName: "Translate", parameters: [:])]),
        .init(id: "trv_day", title: "Travel Day Routine", summary: "Boarding pass, low power, podcast queued.", category: .travel, icon: "suitcase.fill", colorHex: "#00ACC1",
              actions: [.init(identifier: "is.workflow.actions.lowpowermode.set", displayName: "Low Power", parameters: ["state": "on"])]),
        .init(id: "trv_resv", title: "Restaurant Reservation", summary: "Quick OpenTable lookup near hotel.", category: .travel, icon: "fork.knife.circle.fill", colorHex: "#00838F",
              actions: [.init(identifier: "is.workflow.actions.url", displayName: "OpenTable", parameters: ["url": "opentable://"])]),
        .init(id: "trv_transit", title: "Public Transit Card", summary: "Opens Wallet to your transit card.", category: .travel, icon: "tram.fill", colorHex: "#0097A7",
              actions: [.init(identifier: "is.workflow.actions.wallet.open", displayName: "Open Wallet", parameters: [:])]),
        .init(id: "trv_photo", title: "Tourist Photo", summary: "Best camera mode for landmarks.", category: .travel, icon: "camera.fill", colorHex: "#00ACC1",
              actions: [.init(identifier: "is.workflow.actions.camera.open", displayName: "Open Camera", parameters: [:])]),
        .init(id: "trv_tip", title: "Tip Calculator", summary: "Tip + total split by guests.", category: .travel, icon: "percent", colorHex: "#0097A7",
              actions: [.init(identifier: "is.workflow.actions.calc", displayName: "Calculate Tip", parameters: [:])]),
        .init(id: "trv_tz", title: "Time Zone Convert", summary: "Time at home vs your destination.", category: .travel, icon: "globe.americas.fill", colorHex: "#006064",
              actions: [.init(identifier: "is.workflow.actions.date.timezone", displayName: "Convert TZ", parameters: [:])])
    ]

    // MARK: - Productivity
    static let productivity: [ExampleShortcut] = [
        .init(id: "prd_voice", title: "Quick Voice Note", summary: "One-tap voice memo.", category: .productivity, icon: "mic.circle.fill", colorHex: "#43A047",
              actions: [.init(identifier: "is.workflow.actions.recordaudio", displayName: "Record", parameters: [:])]),
        .init(id: "prd_cal", title: "Calendar Add Event", summary: "Adds an event from natural language.", category: .productivity, icon: "calendar.badge.plus", colorHex: "#388E3C",
              actions: [.init(identifier: "is.workflow.actions.calendar.add", displayName: "Add Event", parameters: [:])]),
        .init(id: "prd_remloc", title: "Reminder + Location", summary: "Reminds you when you arrive somewhere.", category: .productivity, icon: "mappin.circle.fill", colorHex: "#2E7D32",
              actions: [.init(identifier: "is.workflow.actions.reminders.add", displayName: "Add Reminder", parameters: [:])]),
        .init(id: "prd_qr", title: "QR Scanner", summary: "Opens camera in QR scan mode.", category: .productivity, icon: "qrcode.viewfinder", colorHex: "#43A047",
              actions: [.init(identifier: "is.workflow.actions.qr.scan", displayName: "Scan QR", parameters: [:])]),
        .init(id: "prd_pdf", title: "PDF from Photos", summary: "Combine selected photos into a PDF.", category: .productivity, icon: "doc.fill", colorHex: "#388E3C",
              actions: [.init(identifier: "is.workflow.actions.pdf.create", displayName: "Make PDF", parameters: [:])]),
        .init(id: "prd_calc", title: "Quick Calculator", summary: "Math input, instant result.", category: .productivity, icon: "plus.slash.minus", colorHex: "#66BB6A",
              actions: [.init(identifier: "is.workflow.actions.calc", displayName: "Calc", parameters: [:])]),
        .init(id: "prd_batt", title: "Battery Health", summary: "Reads current battery + percent.", category: .productivity, icon: "battery.75percent", colorHex: "#43A047",
              actions: [.init(identifier: "is.workflow.actions.device.battery", displayName: "Battery", parameters: [:])]),
        .init(id: "prd_storage", title: "Storage Cleanup", summary: "Opens Storage settings for cleanup.", category: .productivity, icon: "internaldrive.fill", colorHex: "#1B5E20",
              actions: [.init(identifier: "is.workflow.actions.url", displayName: "Open Settings", parameters: ["url": "App-Prefs:General&path=STORAGE"])]),
        .init(id: "prd_wifi", title: "Wi-Fi QR Share", summary: "Generate a QR for guest Wi-Fi.", category: .productivity, icon: "wifi", colorHex: "#388E3C",
              actions: [.init(identifier: "is.workflow.actions.qr.generate", displayName: "Generate QR", parameters: [:])]),
        .init(id: "prd_hotspot", title: "Hotspot Toggle", summary: "Quickly toggles personal hotspot.", category: .productivity, icon: "personalhotspot", colorHex: "#2E7D32",
              actions: [.init(identifier: "is.workflow.actions.hotspot.toggle", displayName: "Hotspot", parameters: [:])]),
        .init(id: "prd_air", title: "Airplane Mode", summary: "One-tap airplane on/off.", category: .productivity, icon: "airplane.circle", colorHex: "#43A047",
              actions: [.init(identifier: "is.workflow.actions.airplane.set", displayName: "Airplane", parameters: [:])]),
        .init(id: "prd_low", title: "Low Power Mode", summary: "Toggles low power instantly.", category: .productivity, icon: "bolt.slash.fill", colorHex: "#66BB6A",
              actions: [.init(identifier: "is.workflow.actions.lowpowermode.set", displayName: "Low Power", parameters: [:])]),
        .init(id: "prd_brief", title: "Daily Brief", summary: "Weather + calendar + top news.", category: .productivity, icon: "newspaper.fill", colorHex: "#388E3C",
              actions: [.init(identifier: "is.workflow.actions.weather.current", displayName: "Weather", parameters: [:])]),
        .init(id: "prd_weather", title: "Weather Today", summary: "Reads today's forecast.", category: .productivity, icon: "cloud.sun.fill", colorHex: "#43A047",
              actions: [.init(identifier: "is.workflow.actions.weather.current", displayName: "Weather", parameters: [:])]),
        .init(id: "prd_news", title: "News Highlights", summary: "Top headlines from Apple News.", category: .productivity, icon: "newspaper", colorHex: "#1B5E20",
              actions: [.init(identifier: "is.workflow.actions.url", displayName: "Open News", parameters: ["url": "applenews://"])])
    ]

    // MARK: - Creative
    static let creative: [ExampleShortcut] = [
        .init(id: "crt_voice", title: "New Voice Memo", summary: "Captures a quick voice memo to Notes.", category: .creative, icon: "waveform.circle.fill", colorHex: "#8E24AA",
              actions: [.init(identifier: "is.workflow.actions.recordaudio", displayName: "Record", parameters: [:])]),
        .init(id: "crt_idea", title: "Blog Idea Capture", summary: "Saves text + clipboard to a writing inbox.", category: .creative, icon: "lightbulb.fill", colorHex: "#7B1FA2",
              actions: [.init(identifier: "is.workflow.actions.appendnote", displayName: "Append Idea", parameters: [:])]),
        .init(id: "crt_md", title: "Markdown to PDF", summary: "Converts Markdown text into a PDF.", category: .creative, icon: "doc.richtext.fill", colorHex: "#9C27B0",
              actions: [.init(identifier: "is.workflow.actions.pdf.create", displayName: "Make PDF", parameters: [:])]),
        .init(id: "crt_color", title: "Color Picker from Photo", summary: "Pulls hex codes from selected image.", category: .creative, icon: "eyedropper.full", colorHex: "#AB47BC",
              actions: [.init(identifier: "is.workflow.actions.image.color", displayName: "Pick Color", parameters: [:])]),
        .init(id: "crt_resize", title: "Photo Resize Batch", summary: "Resize multiple photos to a target width.", category: .creative, icon: "photo.stack.fill", colorHex: "#8E24AA",
              actions: [.init(identifier: "is.workflow.actions.image.resize", displayName: "Resize", parameters: ["width": "1080"])]),
        .init(id: "crt_bg", title: "Background Remover", summary: "Removes background from photos via Vision.", category: .creative, icon: "scissors", colorHex: "#7B1FA2",
              actions: [.init(identifier: "is.workflow.actions.image.removebg", displayName: "Remove BG", parameters: [:])]),
        .init(id: "crt_gif", title: "GIF from Live Photo", summary: "Convert a Live Photo to a shareable GIF.", category: .creative, icon: "rectangle.stack.fill.badge.plus", colorHex: "#9C27B0",
              actions: [.init(identifier: "is.workflow.actions.image.gif", displayName: "Make GIF", parameters: [:])]),
        .init(id: "crt_trim", title: "Video Trim 60s", summary: "Auto-trim a video to 60 seconds for socials.", category: .creative, icon: "scissors.badge.ellipsis", colorHex: "#AB47BC",
              actions: [.init(identifier: "is.workflow.actions.video.trim", displayName: "Trim", parameters: ["duration": "60"])])
    ]

    // MARK: - Wellness
    static let wellness: [ExampleShortcut] = [
        .init(id: "wel_grat", title: "Gratitude Journal", summary: "Three things you're grateful for, saved.", category: .wellness, icon: "heart.text.clipboard.fill", colorHex: "#26A69A",
              actions: [.init(identifier: "is.workflow.actions.appendnote", displayName: "Append Note", parameters: ["note": "Grateful for: "])]),
        .init(id: "wel_mood", title: "Mood Tracker", summary: "Logs current mood + brief context.", category: .wellness, icon: "face.smiling", colorHex: "#00897B",
              actions: [.init(identifier: "is.workflow.actions.health.mood", displayName: "Log Mood", parameters: [:])]),
        .init(id: "wel_anx", title: "Anxiety Reset", summary: "Box breathing + grounding 5-4-3-2-1.", category: .wellness, icon: "wind.circle.fill", colorHex: "#26A69A",
              actions: [.init(identifier: "is.workflow.actions.timer.start", displayName: "3min Breath", parameters: ["minutes": "3"])]),
        .init(id: "wel_cold", title: "Cold Shower Timer", summary: "Builds up gradually with audio cues.", category: .wellness, icon: "drop.degreesign.fill", colorHex: "#00796B",
              actions: [.init(identifier: "is.workflow.actions.timer.start", displayName: "Cold Timer", parameters: ["minutes": "2"])]),
        .init(id: "wel_aff", title: "Daily Affirmation", summary: "Speaks one of your saved affirmations.", category: .wellness, icon: "quote.bubble.fill", colorHex: "#4DB6AC",
              actions: [.init(identifier: "is.workflow.actions.text.speak", displayName: "Speak", parameters: ["text": "You are doing great."])])
    ]
}
