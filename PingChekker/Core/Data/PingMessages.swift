//
//  PingMessages.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 20/03/25.
//

import Foundation

struct PingMessages {
    
    // --- BAGIAN 1: LATENCY MESSAGES (KECEPATAN) ---
    // Fokus: "Seberapa Cepat?" (Durasi kirim-terima)
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
    
    // --- BAGIAN 2: QUALITY RECOMMENDATIONS (KESTABILAN) ---
    // Fokus: "Seberapa Konsisten?" (Jitter, Loss, Gangguan)
    // Copywriting ini fokus pada GEJALA ketidakstabilan (Robot, Teleport, Buffer)
    static let recommendations: [String: String] = [
        "perfect": "💎 KONEKSI ROCK-SOLID. Sinyal stabil tanpa 'detak jantung' tambahan. Wajib hukumnya untuk Turnamen E-Sport atau Trading Frekuensi Tinggi.",
        
        "stable": "✅ SANGAT KONSISTEN. Variasi sinyal minim. Sangat aman untuk Meeting Penting (Zoom) agar suara jernih, atau Streaming film tanpa buffering.",
        
        "unstable": "⚠️ SINYAL 'GOYANG' (Jitter Tinggi). Kecepatan mungkin oke, tapi tidak konsisten. Efek: Game Online akan terasa 'teleport' (rubber-banding) dan suara Call jadi robot.",
        
        "laggy": "🐢 RESPON LAMBAT. Ada jeda signifikan antara klik dan respon server. Hindari aktivitas real-time (Game/Call). Cocok hanya untuk browsing teks atau download ditinggal tidur.",
        
        "critical": "⛔ GANGGUAN BERAT. Sinyal sangat fluktuatif. Video call pasti freeze, game pasti disconnect. Coba restart modem atau pindah posisi duduk.",
        
        "packet_loss": "💔 KEBOCORAN DATA (Packet Loss). Sebagian data hilang di tengah jalan. Ini musuh utama Gamer & Streamer. Game akan patah-patah kasar, file upload bisa corrupt.",
        
        "offline": "🔌 TERPUTUS TOTAL. Tidak ada sambungan internet sama sekali. Cek kabel LAN atau pastikan WiFi sudah terhubung dengan benar."
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
