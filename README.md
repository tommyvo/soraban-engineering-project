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

In the project root:

```bash
bin/dev
```

This will start Rails, Sidekiq, and the frontend (Vite/React) server.

## 6. Running Tests

### Backend (RSpec)
```bash
bundle exec rspec
```

### Frontend (Jest)
```bash
cd frontend
yarn test
```

---

## Troubleshooting
- Ensure PostgreSQL and Redis are running (`brew services list`).
- If you see errors, try restarting your terminal and running the steps again.
- For more help, see the comments in each section above.
