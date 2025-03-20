//
//  PingMessages.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 20/03/25.
//

import Foundation

struct PingMessages {
    static let messages: [String: [String]] = [
        "elite" : [
            "💼 Kerja remote? Meeting lancar tanpa delay. Bisa multitasking tanpa drama!",
            "🎮 Reflex secepat pro player! No lag, no excuses. Aim auto headshot! 🔫",
            "📺 Streaming 4K? No buffering, no gangguan. Maraton drama Korea tanpa skip!",
            "🗣️ Video call sehalus ngobrol langsung. Kamu bisa roasting temen real-time tanpa jeda! 🔥",
            "🎵 Spotify? Download playlist 100 lagu dalam hitungan detik. Go crazy!"
        ],
        "good" : [
            "💼 Zoom meeting aman, nggak bakal freeze di posisi paling jelek.",
            "🎮 Masih bisa main Valorant atau PUBG tanpa teleport tiba-tiba. Stabil kayak hubungan impian.",
            "📺 Netflix 1080p? Santai, nggak bakal buffering, asal WiFi nggak rebutan.",
            "🗣️ Call Discord atau WhatsApp lancar, nggak perlu ngomong ‘Halo? Masih denger gak?’",
            "🎵 Mau buka IG Story atau TikTok? Geser kanan-kiri tanpa delay!"
        ],
        "good enough" : [
            "💼 Bisa kerja remote, tapi kadang ada delay dikit pas screenshare.",
            "🎮 Masih playable, tapi jangan heran kalau tiba-tiba nembak musuh tapi damage masuknya telat.",
            "📺 Streaming masih lancar, tapi kadang suka buffer pas adegan klimaks.",
            "🗣️ Panggilan suara masih oke, tapi kalau video call suka ada freeze random.",
            "🎵 TikTok dan Instagram lancar, tapi kalau lagi lemot, harus refresh biar update."
        ],
        "enough" : [
            "💼 Bisa browsing dan kerja, tapi loading file agak nyendat. Upload? Harus sabar.",
            "🎮 Game MOBA masih bisa, tapi FPS? Siap-siap teleport ke dimensi lain.",
            "📺 YouTube bisa jalan, asal jangan berharap kualitas lebih dari 720p.",
            "🗣️ Video call delay setengah detik. Jangan ngobrol cepat, bisa kayak talking over.",
            "🎵 Streaming musik oke, tapi kalau offline mode, lebih baik download dulu."
        ],
        "slow" : [
            "💼 Kirim email masih bisa, tapi kalau upload file? Ambil kopi dulu.",
            "🎮 Main game? Cuma kalau niat olahraga jantung karena delay parah.",
            "📺 Netflix masih bisa, tapi mungkin butuh buffering kayak era YouTube 2008.",
            "🗣️ Chat telat masuk, jadi siap-siap dikira slow respon padahal nggak.",
            "🎵 Spotify bisa muter lagu, tapi kadang suka stuck di loading screen."
        ],
        "unplayable" : [
            "💼 Internetnya lebih lambat dari niat buat kerja. Browsing aja nyiksa.",
            "🎮 Main game online? Jangan. Ini cuma bisa buat game offline.",
            "📺 YouTube? 144p pun masih buffering. Balik ke DVD aja kali ya.",
            "🗣️ Chat masuknya delay, kayak orang yang bales WhatsApp seminggu sekali.",
            "🎵 Musik streaming? Nggak, ini malah kasih vibes radio rusak."
        ],
        "no connection" : [
            "No Connection!"
        ]
    ]
    
    // akses message array berdasarkan categorynya, lalu di ambil secara random
    static func getRandomMessage(for category: String) -> String {
        return messages[category]?.randomElement() ?? "Maaf status koneksimu tidak terdeteksi. Cek kembali dan coba lagi."
    }
}
