

PingChekker 📡

PingChekker is a native macOS utility tool designed to monitor internet connection quality in real-time. Unlike standard terminal ping commands, PingChekker translates raw latency data into human-readable statuses (e.g., "Elite", "Good", "Lag") and visualizes stability using a compact, widget-style interface.


<p align="center">
<!-- Ganti link ini dengan screenshot aplikasimu yang "Screenshot 2025-11-27..." tadi -->
<img src="https://github.com/user-attachments/assets/350d5552-a218-416d-9d36-733f928f549f" alt="PingChekker Screenshot" width="600"/>
</p>

🚀 Key Features

Real-time Monitoring: Visualizes latency (ms) with a dynamic speedometer.

Stability Analysis: Calculates Jitter and Packet Loss to determine true network quality, not just speed.

Session Average: Provides a long-term quality score based on your entire session duration.

Humanized Feedback: Contextual messages (e.g., "Perfect for gaming", "Good for streaming") based on ping categories.

Native Design: Built with SwiftUI, featuring a translucent glass effect (NSVisualEffectView) that blends perfectly with the macOS desktop.

Menu Bar Support: (Coming Soon) Quick access from the status bar.

🛠 How It Works

PingChekker goes beyond a simple ping command. It uses a custom buffering logic to ensure data accuracy and UI stability.

1. The Core Mechanism (Micro Process)

At its core, the app utilizes Apple's SimplePing sample code to handle low-level ICMP packets. It resolves the host (default: 8.8.8.8), sends a packet, and measures the time taken for the response.

2. The Business Logic (Macro Process)

To prevent UI jitter and provide meaningful data, PingChekker implements a Sampling & Buffering Service:

Sampling: Instead of updating the UI on every single packet, the app collects data into a buffer (e.g., 10 samples).

Calculation: Once the buffer is full, it calculates:

Average Latency: To smooth out outliers.

Jitter: The variance between ping times (crucial for gaming stability).

Packet Loss: The percentage of failed packets.

Reporting: The processed data is then sent to the ViewModel to update the UI color, text, and gauge.

🏗 Architecture

The project follows a clean MVVM (Model-View-ViewModel) pattern with a separation of concerns between Core components and Features.

PingChecker/
├── Core/
│   ├── UIComponents/    # Reusable Views (Speedometer, etc.)
│   └── Utils/           # Helpers & SimplePing Library
│
├── Features/
│   └── InternetMonitor/
│       ├── Services/    # PingService (Business Logic & Buffering)
│       ├── ViewModels/  # HomeViewModel (Data Transformation)
│       └── Views/       # HomeView (UI Layout)
│
└── App/                 # App Entry Point & Window Configuration


💻 Tech Stack

Language: Swift

UI Framework: SwiftUI

Networking: Foundation, CFNetwork (via SimplePing)

Platform: macOS 12.0+

📦 Installation

Clone the repository:

git clone [https://github.com/yourusername/PingChekker.git](https://github.com/yourusername/PingChekker.git)


Open PingChekker.xcodeproj in Xcode.

Ensure App Sandbox is enabled in "Signing & Capabilities" with "Outgoing Connections (Client)" checked.

Build and Run (Cmd + R).

📝 License

This project is licensed under the MIT License.
