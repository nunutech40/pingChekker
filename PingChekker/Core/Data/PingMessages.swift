//
//  PingMessages.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 20/03/25.
//


import Foundation

struct PingMessages {
    
    // ==========================================
    // MARK: - LATENCY MESSAGES (SPEED & FEEL)
    // ==========================================
    // String(localized: "...") otomatis masuk ke String Catalog.
    // Default Text = English.
    
    static let messages: [String: [String]] = [
        "elite" : [
            String(localized: "⚡️ Insane! This isn't internet, it's lightning!"),
            String(localized: "🚄 Whoosh! Downloading feels like moving local files."),
            String(localized: "🔥 Cheating-level ping. Enemies die before they even move."),
            String(localized: "💎 God-tier internet. Enjoy it while it lasts!"),
            String(localized: "🚀 Ready to moon? Connection with no brakes!")
        ],
        "good" : [
            String(localized: "✨ Smooth as silk, like a freshly paved highway."),
            String(localized: "🌊 Smooth sailing. Streaming 4K without a thought."),
            String(localized: "👌 Perfect for working while jamming to Spotify."),
            String(localized: "🎮 Game on! Safe, sound, and lag-free."),
            String(localized: "✅ No complaints. Internet doing exactly what it should.")
        ],
        "good enough" : [
            String(localized: "😐 Not bad. Better than mobile data hotspot."),
            String(localized: "☕️ Good for casual work, just don't download big files."),
            String(localized: "🆗 YouTube is fine, just don't push for 4K."),
            String(localized: "🤸‍♀️ Not great, not terrible. At least we're connected."),
            String(localized: "🤏 A tiny delay, but still forgivable.")
        ],
        "enough" : [
            String(localized: "🐢 Patience... good things come to those who wait."),
            String(localized: "🐌 A bit sluggish, like a car overdue for an oil change."),
            String(localized: "📦 Feeling the load times? Go grab a coffee."),
            String(localized: "🤔 Hmm, is everyone on the WiFi right now?"),
            String(localized: "📉 Lower the video resolution to stop the buffering.")
        ],
        "slow" : [
            String(localized: "🛑 Ouch, so heavy. Even Google is thinking twice."),
            String(localized: "😫 Better read a book than wait for this loading."),
            String(localized: "🕸️ Is this the web or a spiderweb? Getting stuck everywhere."),
            String(localized: "🕰️ Feels like 2008 dial-up all over again."),
            String(localized: "💤 Zzz... I'll grow old waiting for this.")
        ],
        "unplayable" : [
            String(localized: "💀 RIP Internet. Just go to sleep."),
            String(localized: "⛔️ Don't force it, you'll get high blood pressure."),
            String(localized: "🧱 This is a brick wall, not internet. Nothing's passing."),
            String(localized: "🆘 SOS! Send emergency signal help!"),
            String(localized: "📵 On and off like a toxic relationship.")
        ],
        "no connection" : [
            String(localized: "👻 Empty... no signs of signal life here."),
            String(localized: "🔌 Plug in the cable first, boss!"),
            String(localized: "❌ Disconnected. Try restarting the modem, might get lucky.")
        ],
        "calculating": [
            String(localized: "🔎 Divining your signal's fortune..."),
            String(localized: "⏳ Hold on, doing the math..."),
            String(localized: "📡 Ping... Pong... Waiting for reply...")
        ],
        "unknown": [
            String(localized: "😵 Status unrecognized."),
            String(localized: "❓ Anomalous data detected.")
        ]
    ]
    
    // ==========================================
    // MARK: - RECOMMENDATIONS (QUALITY CONTEXT)
    // ==========================================
    
    static let recommendations: [String: String] = [
        "perfect": String(localized: "💎 ROCK-SOLID CONNECTION. Stable signal with no extra 'heartbeats'. Mandatory for E-Sports Tournaments or High-Frequency Trading."),
        
        "stable": String(localized: "✅ VERY CONSISTENT. Minimal signal variation. Safe for important meetings (Zoom) for clear audio, or streaming movies without buffering."),
        
        "unstable": String(localized: "⚠️ WOBBLY SIGNAL (High Jitter). Speed might be okay, but inconsistent. Effect: Online games will feel like 'teleporting' (rubber-banding) and calls will sound robotic."),
        
        "laggy": String(localized: "🐢 SLOW RESPONSE. Significant delay between click and server response. Avoid real-time activities (Games/Calls). Good only for browsing text or downloading while sleeping."),
        
        "critical": String(localized: "⛔ SEVERE DISRUPTION. Signal is fluctuating wildly. Video calls will freeze, games will disconnect. Try restarting the modem or moving closer."),
        
        "packet_loss": String(localized: "💔 DATA LEAK (Packet Loss). Parts of data are lost in transit. The main enemy of Gamers & Streamers. Games will stutter badly, uploads may corrupt."),
        
        "offline": String(localized: "🔌 TOTAL DISCONNECTION. No internet connection at all. Check LAN cable or ensure WiFi is connected properly.")
    ]
    
    // Helpers
    static func getRandomMessage(for category: String) -> String {
        let availableMessages = messages[category] ?? messages["unknown"]!
        return availableMessages.randomElement() ?? String(localized: "Status koneksi...")
    }
    
    static func getRecommendation(for conditionKey: String) -> String {
        return recommendations[conditionKey] ?? String(localized: "Menganalisa jaringan...")
    }
}
