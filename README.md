# SYNCO — Women's Health Platform

SYNCO is a Flutter-based women's health platform focused on **PCOS/PMOS, menstrual health, reproductive health, nutrition, lifestyle management, and healthcare access**.

It brings together **personalized health tracking, AI-assisted insights, educational resources, community support, and doctor consultations** into a single platform.

> **Note:** SYNCO is designed as a health-support and education platform. AI-generated insights are not intended to replace professional medical diagnosis or treatment.

---

## 🌸 Platform Overview

SYNCO consists of two primary experiences:

### 👩 User / Patient App

The user app provides:

- Personalized onboarding and health assessment
- Period and symptom tracking
- Health score and wellness tracking
- Sleep, weight, exercise, water, nutrition, mental health, skin and supplement tracking
- AI-based health pattern detection
- Kyra AI health assistant
- AI food scanner
- AI lab-report interpreter
- Doctor discovery and consultation
- Online and offline appointments
- Health-summary sharing
- Whisper Room community
- Learn Corner
- Reminders and wellness routines

### 👨‍⚕️ Doctor App / Panel

The doctor panel allows doctors to:

- Create and manage professional profiles
- Manage appointment requests
- View upcoming and completed appointments
- Conduct call and chat consultations
- View patient health information shared with them
- Access health summaries and relevant reports

---

## 🏗️ Core Architecture

                         SYNCO
                           │
              ┌────────────┴────────────┐
              │                         │
        USER / PATIENT              DOCTOR
             APP                     PANEL
              │                         │
              └────────────┬────────────┘
                           ↓
                      API / BACKEND
                           │
             ┌─────────────┼─────────────┐
             ↓             ↓             ↓
          Firebase         AI         Storage
             │             │             │
       ┌─────┼─────┐       ↓             ↓
       ↓     ↓     ↓     Gemini       Reports
    Auth Firestore RTDB              Images


## 🛠️ Technology Stack

| Layer               | Technologies                       |
| ------------------- | ---------------------------------- |
| **Frontend**        | Flutter, Dart                      |
| **Backend / APIs**  | Node.js, Vercel Serverless APIs    |
| **Authentication**  | Firebase Authentication            |
| **Database**        | Cloud Firestore                    |
| **Realtime Data**   | Firebase Realtime Database         |
| **Storage**         | Firebase Storage                   |
| **AI**              | Google Gemini, `@google/genai`     |
| **Security**        | Firebase Security Rules, App Check |
| **Testing**         | Flutter Test, Firebase Emulator    |
| **Version Control** | Git, GitHub                        |

## 🔄 Application Architecture

User Flow
      
                    LOGIN / SIGN UP
                          │
                          ↓
                 Select User / Doctor
                          │
                          ↓
                    USER PANEL
                          │
                          ↓
                    ONBOARDING
                          │
             ┌────────────┴────────────┐
             ↓                         ↓
      Existing Condition          No Known Condition
             │                         │
             ↓                         ↓
     Management Profile        Early Risk Assessment
             │                         │
             └────────────┬────────────┘
                          ↓
                    USER DASHBOARD
                          │
       ┌──────────────────┼──────────────────┐
       ↓                  ↓                  ↓
 Period Tracker       Health Score        Kiara AI
       │                  │                  │
       ↓                  ↓                  ↓
 Cycle/Symptoms       Health Trackers     Personal AI
                      & Patterns
       │
       └──────────────────────────────────────┐
                                              ↓
                              Food / Lab / Doctor / Learn /
                              Whisper Room / Reminders

Doctor Flow

LOGIN / SIGN UP
      │
      ↓
DOCTOR ONBOARDING
      │
      ├── Professional Information
      ├── Specialization
      ├── Experience
      ├── Consultation Fee
      └── Availability
      │
      ↓
DOCTOR DASHBOARD
      │
 ┌────┼───────────────┐
 ↓    ↓               ↓
New  Today's       Upcoming
Requests Appointments Appointments
      │
      ↓
Patient Overview
      │
      ├── Health Summary
      ├── Period Information
      ├── Shared Health Data
      ├── Lab Reports
      └── AI-generated Questions

## 🤖 AI Features

SYNCO integrates AI-powered features using Google Gemini:

Kyra AI — Personalized health assistant using relevant user-provided health context
Food Scanner — Food identification and nutrition-oriented guidance
Lab Report Interpreter — Simplifies uploaded laboratory reports
Health Pattern Detection — Identifies trends and correlations from tracked health data

AI features are designed for education, personalization and wellness support, not standalone medical diagnosis.

## 📁 Project Structure

SYNCO/
│
├── lib/
│   ├── core/                    # Core app configuration & shared functionality
│   ├── features/                # Main application features and modules
│   ├── models/                  # Application data models
│   ├── providers/               # State management & app providers
│   ├── app.dart                 # Application configuration
│   ├── main.dart                # Application entry point
│
├── assets/
│   └── images/                  # App images and visual assets
│
├── test/                        # Application tests
│
├── android/                     # Android platform configuration
├── ios/                         # iOS platform configuration
├── web/                         # Web platform configuration
├── windows/                     # Windows platform configuration
├── macos/                       # macOS platform configuration
├── linux/                       # Linux platform configuration
│
├── firebase.json                # Firebase configuration
├── firestore.rules              # Firestore security rules
├── storage.rules                # Firebase Storage rules
├── pubspec.yaml                 # Flutter dependencies & configuration
└── README.md                    # Project documentation

## Local Development

Frontend
cd frontend
flutter pub get
flutter run

Backend
cd backend
npm install

Firebase Emulator
firebase emulators:start

Vercel API
npx vercel dev

Environment Variables
Backend environment variables:

FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-client-email
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
GEMINI_API_KEY=your-gemini-api-key

Never commit .env files, private keys, service-account credentials, or API keys to GitHub.

## Testing

Flutter
flutter test

Backend
npm test

API tests
node test-api.js
node test-summary.js
node test-food.js
node test-pattern.js

Firebase Rules
npx firebase emulators:exec --project synco-test-project "npm test"


## 🔐 Security & Privacy

SYNCO handles sensitive health-related information and follows a privacy-focused approach.

The application uses:

Firebase Authentication
Role-based access control
Firestore Security Rules
Firebase Storage Rules
Protected API credentials
Controlled patient-doctor data sharing
User consent for health-data sharing
Secure storage for uploaded reports and documents

## 🎯 Project Goal

SYNCO aims to create a unified digital ecosystem for women's health by bringing together:

Assess → Track → Understand → Manage → Connect

The platform helps users better understand and manage their health while enabling doctors to access relevant, user-authorized information for more informed consultations.