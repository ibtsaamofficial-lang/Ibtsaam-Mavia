# Ibtsaam Mavia — Graphic Designer Portfolio

An interactive, high-performance web portfolio for **Ibtsaam Mavia** (Graphic Designer & Video Creator), featuring smooth canvas scroll video scrub animation, interactive project showcase galleries, and responsive UGC video ad playback.

---

## 🌟 Features

- **Smooth Scroll Scrub Engine:** 40-frame high-resolution canvas video scrubbing with momentum physics and lerp interpolation.
- **Interactive Project Galleries:**
  - **Social Media Design:** 9 curated social media campaigns and poster designs with full-resolution lightboxes.
  - **UI/UX Design:** Mobile and web interface case studies.
  - **Branding Design:** Complete visual identity suites and merchandise mockups.
  - **Illustrator & Digital Art:** Handcrafted vector logos, character art, and digital illustrations.
  - **UGC Ads:** Auto-playing banner preview and interactive modal featuring 4 real UGC-style video ads with fullscreen video lightbox and custom playback controls.
- **Responsive Navigation:** Fixed glassmorphism navbar and interactive 9-stage side dot indicator.
- **Contact Dock:** Verified social and contact links featuring the official Instagram brand mark.

---

## 🚀 Running Locally

### Option 1: PowerShell High-Performance Server (Recommended)
This repository includes a lightweight, zero-dependency C# / .NET `server.ps1` HTTP server with HTTP 206 Partial Content video streaming support:

```powershell
powershell -ExecutionPolicy Bypass -File server.ps1
```

Then open your browser at:
```
http://localhost:3000/
```

### Option 2: Any Static Web Server
You can also use Python, Node, or VS Code Live Server:

```bash
# Python
python -m http.server 3000

# Node.js
npx serve .
```

---

## 📁 Project Structure

```
├── index.html          # Main portfolio application
├── server.ps1          # .NET HttpListener local streaming server
├── frames/             # 40-frame canvas scroll animation sequence
├── assests/            # Portfolio media assets (branding, UI/UX, social, UGC ads, illustrations)
└── README.md           # Documentation
```

---

## 👤 Designer Profile

- **Name:** Ibtsaam Mavia
- **Role:** Graphic Designer & UGC Ads Creator
- **Email:** ibtsaamofficial@gmail.com
- **Instagram:** [@maviaibtsaam](https://instagram.com/maviaibtsaam)
- **Phone:** +92 3367657232
