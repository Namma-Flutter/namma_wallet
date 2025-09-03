# Namma Wallet - Project Overview

## Purpose
Namma Wallet is an open-source Flutter mobile application that lets users save, organize, and view their tickets from various sources including SETC buses, trains, and other types of passes. The app parses ticket data and generates beautiful digital ticket designs. Unlike Apple Wallet or Google Wallet, which support only specific formats, Namma Wallet is a flexible, community-driven solution.

## Key Features
- **Ticket Import**: Save tickets from SMS, QR codes, PDFs, or manual entry
- **Beautiful Ticket UI**: Auto-generated, clean, and minimal ticket design
- **Multiple Sources**: Works with SETC, buses, trains, and general tickets
- **Organized Storage**: Keep all tickets and passes in one place
- **Open Source**: Built by the community, for the community

## Architecture
- **Feature-based architecture** with clear separation between presentation and application layers
- **Bottom navigation** with three main sections: Home, Calendar, Profile
- **Service-oriented architecture** for core functionality (PDF, SMS, file picker services)
- **Material Design** UI components throughout the app

## Target Platforms
- Android
- iOS (configured with Xcode project)