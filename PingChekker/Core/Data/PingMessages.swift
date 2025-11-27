//
//  PingMessages.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 20/03/25.
//

import Foundation

struct PingMessages {
    
    // --- BAGIAN 1: LATENCY MESSAGES (EMOSIONAL / FEELING) ---
    // Fokus: Reaksi terhadap kecepatan sesaat. Nada: Kasual & Fun.
    static let messages: [String: [String]] = [
        "elite" : [
            "⚡️ Gila! Ini sih bukan internet, ini kilat!",
            "🚄 Wusss! Download file berasa mindahin folder lokal.",
            "🔥 Ping segini sih curang, musuh belum gerak udah mati duluan.",
            "💎 Definisi internet sultan. Nikmatin selagi bisa!",
            "🚀 Siap terbang ke bulan? Koneksi tanpa rem!"
        ],
        "good" : [
            "✨ Mulus banget, kayak jalan tol baru diaspal.",
            "🌊 Lancar jaya, streaming 1080p tanpa mikir.",
            "👌 Asik nih buat kerja sambil dengerin Spotify.",
            "🎮 Gas main game, aman sentosa damai sejahtera.",
            "✅ Nggak ada komplain, internet sebagaimana mestinya."
        ],
        "good enough" : [
            "😐 Lumayan lah, daripada pake kuota hp.",
            "☕️ Bisa buat kerja santai, asal jangan download file gede barengan.",
            "🆗 Masih oke buat YouTube, tapi jangan maksa 4K ya.",
            "🤸‍♀️ Not bad, not great. Yang penting connect.",
            "🤏 Sedikit delay tapi masih bisa dimaafkan."
        ],
        "enough" : [
            "🐢 Sabar... orang sabar disayang Tuhan.",
            "🐌 Agak berat tarikannya, kayak motor telat ganti oli.",
            "📦 Loading-nya kerasa, mending ambil kopi dulu.",
            "🤔 Hmm, lagi rame ya yang pake WiFi?",
            "📉 Turunin resolusi video biar nggak muter-muter."
        ],
        "slow" : [
            "🛑 Duh, berat banget. Buka Google aja mikir.",
            "😫 Mending baca buku daripada nungguin loading.",
            "🕸️ Ini internet apa jaring laba-laba? Nyangkut mulu.",
            "🕰️ Berasa balik ke jaman warnet 2008.",
            "💤 Zzz... keburu tua nungguin ini."
        ],
        "unplayable" : [
            "💀 RIP Internet. Mending tidur.",
            "⛔️ Jangan dipaksa, nanti darah tinggi.",
            "🧱 Ini tembok, bukan internet. Nggak nembus.",
            "🆘 Tolong, butuh bantuan sinyal darurat!",
            "📵 Putus nyambung kayak hubungan toxic."
        ],
        "no connection" : [
            "👻 Hampa... tidak ada tanda-tanda kehidupan sinyal.",
            "🔌 Kabelnya colok dulu bos!",
            "❌ Disconnect. Coba restart modem, siapa tau hoki."
        ],
        "calculating": [
            "🔎 Sedang menerawang nasib sinyalmu...",
            "⏳ Sabar, lagi ngitung...",
            "📡 Ping... Pong... Menunggu balasan..."
        ],
        "unknown": [
            "😵 Status tidak dikenali.",
            "❓ Data aneh terdeteksi."
        ]
    ]
    
    // --- BAGIAN 2: QUALITY RECOMMENDATIONS (LOGIS / ADVISORY) ---
    // Fokus: Saran teknis berdasarkan kestabilan (Jitter & Loss). Nada: Informatif & Tegas.
    static let recommendations: [String: String] = [
        "perfect": "✅ SANGAT DIREKOMENDASIKAN untuk Game Kompetitif (Valorant/PUBG), Day Trading, & Upload File Besar.",
        "stable": "✅ AMAN untuk Zoom Meeting, Netflix HD, & YouTube. Cukup stabil untuk penggunaan harian.",
        "unstable": "⚠️ RISIKO LAG SPIKE. Streaming video aman (buffering), tapi Game Online & Video Call akan terasa patah-patah.",
        "laggy": "⚠️ TIDAK DISARANKAN untuk aktivitas realtime. Terasa delay saat mengetik atau klik. Fokus browsing teks saja.",
        "critical": "⛔️ KONEKSI BURUK. Latensi terlalu tinggi. Hindari konten video, gunakan hanya untuk pesan teks.",
        "packet_loss": "⛔️ JARINGAN RUSAK (Packet Loss). Data hilang di jalan. Hindari transaksi penting atau upload data.",
        "offline": "❌ TIDAK TERHUBUNG. Periksa sambungan WiFi atau kabel LAN Anda."
    ]
    
    // Fungsi ambil pesan Latency (Random)
    static func getRandomMessage(for category: String) -> String {
        let availableMessages = messages[category] ?? messages["unknown"]!
        return availableMessages.randomElement() ?? "Status koneksi..."
    }
    
    // Fungsi ambil rekomendasi Quality (Static/Fixed)
    static func getRecommendation(for conditionKey: String) -> String {
        return recommendations[conditionKey] ?? "Menganalisa jaringan..."
    }
}
