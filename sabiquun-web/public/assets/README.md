# Assets Directory

This directory contains all static assets for the Sabiquun web application.

## Image Assets

### App Icon
**Location:** `images/app-icon/`

Place the Sabiquun app icon here:
- `logo.png` - Main app logo (recommended: 512x512px or higher, square)
- `logo-white.png` (optional) - White version for dark backgrounds
- `favicon.ico` (optional) - Favicon for browser tabs

### App Store Badge
**Location:** `images/app-store/`

Place the App Store badge/screenshot here:
- `badge.png` - App Store download badge (official Apple badge recommended)
- `screenshots/` (optional) - App Store screenshots for marketing

Expected dimensions: Standard App Store badge is 120x40px (or higher resolution for retina displays)

### Play Store Badge
**Location:** `images/play-store/`

Place the Google Play badge/screenshot here:
- `badge.png` - Google Play download badge (official Google badge recommended)
- `screenshots/` (optional) - Play Store screenshots for marketing

Expected dimensions: Standard Google Play badge is 135x40px (or higher resolution for retina displays)

## Usage in Code

After placing your images, you can reference them in your Next.js components like this:

```jsx
import Image from 'next/image'

// App Icon
<Image src="/assets/images/app-icon/logo.png" alt="Sabiquun" width={512} height={512} />

// App Store Badge
<Image src="/assets/images/app-store/badge.png" alt="Download on App Store" width={120} height={40} />

// Play Store Badge
<Image src="/assets/images/play-store/badge.png" alt="Get it on Google Play" width={135} height={40} />
```

## Official Badge Resources

- **Apple App Store:** https://developer.apple.com/app-store/marketing/guidelines/#badges
- **Google Play:** https://play.google.com/intl/en_us/badges/

## Notes

- All images should be optimized for web (compressed PNG or WebP format)
- Use high-resolution images (2x or 3x) for better display on retina screens
- Next.js will automatically optimize images during build
