# Bookkeeping System with Automated Categorization

This application is a scalable bookkeeping system designed for efficient transaction management and review. It allows users to manually add or bulk import transactions, automatically categorize them using flexible rule-based logic, and flag anomalies for review. The system features real-time updates via websockets (ActionCable + Redis), enabling instant feedback on transaction changes across all connected clients. Built with Ruby on Rails and React, it is optimized for handling large datasets and provides a user-friendly dashboard for bulk actions, anomaly detection, and streamlined financial oversight.

# Local Setup & Usage Guide

## Prerequisites

- macOS (tested)
- Homebrew (https://brew.sh/)

## 1. Install System Dependencies via Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install ruby
brew install postgresql
brew install redis
brew install node
brew install yarn
```

## 2. Setup Database & Redis

```bash
brew services start postgresql
brew services start redis
```

## 3. Setup Rails Backend

```bash
bundle install
bin/rails db:create
```

## 4. Setup Frontend

```bash
cd frontend
yarn install
```

## 5. Running the App (Dev Mode)

Start the Rails API server and Sidekiq:

```bash
bin/dev
```

By default, the server is running on port `3000`

Start the front end Vite server:

```bash
cd frontend
yarn vite
```

Goto http://localhost:5173/ to see it.
## 6. Running Tests

### Backend (RSpec)
```bash
bundle exec rspec
```

---

## Feature Overview & Usage

### Real-Time Updates (ActionCable + Redis)

- All transaction changes (add, update, delete, bulk categorize, CSV import) are broadcast in real-time to all connected clients using ActionCable and Redis.
- No manual refresh is needed—UI updates instantly for all users.
- **How it works:**
    - Rails backend broadcasts transaction changes to a `transactions` channel.
    - React frontend subscribes to this channel and updates the UI live.
    - Redis enables cross-process and background job broadcasting.

### CSV Import

- Import transactions in bulk by uploading a CSV file from the dashboard.
- The import runs as a background job (Sidekiq), so large files do not block the UI.
- Real-time progress: As transactions are imported, they appear live in the UI.
- Handles malformed rows, missing fields, and duplicate detection.

### Rule Management & Automated Categorization

- Create rules to auto-categorize transactions (e.g., "If description contains 'Uber', set category to 'Transport'").
- Rules are applied automatically to new and imported transactions.
- Rules can be managed from the dashboard (add, edit, delete).

### Bulk Categorization

- Select multiple transactions in the UI and assign a category in one action.
- Bulk actions are broadcast in real-time to all clients.

### Anomaly Detection

- The system flags transactions that are:
    - Unusually large compared to user history
    - Potential duplicates (same date, amount, and description)
    - Missing required metadata (e.g., blank description)
- Flagged transactions are highlighted in the dashboard for review.

### Background Jobs (Sidekiq)

- CSV import and other heavy tasks run in the background using Sidekiq.
- Ensure Redis is running for both Sidekiq and ActionCable.
- Monitor Sidekiq jobs at `http://localhost:3000/sidekiq` (if enabled).

## TODO

- [ ] Add pagination to transaction lists for better performance with large datasets
- [ ] Add user accounts and authentication using Devise

## Advanced Troubleshooting & Tips

- **ActionCable not updating?**
    - Ensure Redis is running (`brew services start redis`).
    - Check that `config/cable.yml` uses the Redis adapter in development.
    - Confirm allowed origins in `config/environments/development.rb` include your frontend URL.
- **CSV import not showing new transactions?**
    - Make sure Sidekiq is running (`bin/dev` starts it by default).
    - Check Sidekiq logs for errors.
- **Tests failing due to ActionCable?**
    - Broadcasting is disabled in test mode to avoid flaky tests.
- **Frontend not updating?**
    - Check browser console for websocket errors.
    - Restart both Rails and Vite servers if needed.

---
- If you see errors, try restarting your terminal and running the steps again.
- For more help, see the comments in each section above.

---

# 👇 Original Posting Below 👇

# Soraban Engineering Project
The following is a take-home project for Soraban engineering candidates.

## Submission Instructions
- Fork the repository
- Create a pull request to your forked repository (not the origin Soraban repository) with your project submission
- In the pull request, include any necessary sample files and a Loom (or other video) showcasing the functionality you built and explains how the code works
- Submit the link to your pull request

# **Scalable Bookkeeping System with Automated Categorization**

## **Objective**

Build a **minimal yet scalable bookkeeping system** with the following features:

1. **Record & Import Transactions** – Users can manually add transactions or import a CSV.
2. **Bulk Actions & Automated Categorization** – Users can categorize multiple transactions at once, and automatically assign category (AI-based or rule based).
3. **Anomaly Detection** – Identify and flag unusual/suspicous transactions (e.g., large amounts, duplicates, missing metadata).
4. **Scalability & Performance Optimization** – Efficiently handle large data sets (e.g., 1m+ transactions).
5. **User-friendly Review System** – A dashboard that highlights transactions needing review.

## **Tech Stack**

- **Backend:** Ruby on Rails (preferred), Node.js, Django, or similar.
- **Frontend:** React (preferred) or Vue.js.
- **Database:** PostgreSQL (preferred) or MySQL.

## **Project Requirements**

### **1. Record & Import Transactions**

- Users can **manually add transactions** (date, description, amount, category).
- Users can **import a CSV file** containing transactions.
- CSV parsing should handle **edge cases** (missing fields, malformed data, duplicates).

### **2. Bulk Actions & Rule-based Categorization**

- Users can **select multiple transactions** and apply bulk categorization.
- Users can create **rules** like:
    - “If the description contains ‘Amazon’, categorize as ‘Shopping’.”
    - “If amount > $1000, flag as ‘High Value’.”
- **Rules should apply automatically** when new transactions are added.

### **3. Anomaly Detection & Fraud Prevention (Challenging Part)**

- Identify transactions that are:
    - **Unusual in amount** compared to past user behavior.
    - **Potential duplicates** (same amount, date, with same descriptions).
    - **Incomplete/missing metadata** (e.g., description missing).
- Flag these anomalies and display them on the **Review Dashboard (Step 5)**

### **4. Scalability & Performance Optimization**

- Your system should handle **1m+ transactions efficiently**.
- Consider **indexing, caching, or batch processing** for performance.

### **5. Review System & UX (Final Challenge)**

- A simple **dashboard** that highlights:
    - **Uncategorized transactions** needing user review.
    - **Flagged anomalies** requiring manual verification.
- Users should be able to **approve, edit, or delete** flagged transactions.

## **Bonus Challenges (For the Overachievers)**

1. **Basic API for Transactions** – Expose a REST API for CRUD operations.
2. **Real-time Anomaly Detection** – Use WebSockets or polling for updates.
3. **Graph-based Spending Summary** – Show user spending trends.

## **What We’re Evaluating**

✅ **Code Quality & Architecture** – Clean, modular, and scalable.

✅ **Performance & Efficiency** – Handles large datasets without slowdowns.

✅ **Complex Logic Implementation** – Anomaly detection & rules engine.

✅ **Good UX for Complex Actions** – Well-designed transaction review.

✅ **AI Resistance** – Requires thoughtful **business logic, rule handling, and anomaly detection**, which AI struggles to generate effectively.

✅ **Problem-Solving Skills** – Ability to balance features, scalability, and performance.

## Similar Products Examples for Inspiration

- Kick.co
- Quickbooks Online
- Xero
