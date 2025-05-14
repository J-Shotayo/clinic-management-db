# Clinic Management System - Database

## Project Title
Clinic Management System Database

## Description
This project implements a complete relational database for a clinic management system using MySQL. The database is designed to handle all aspects of clinic operations including:

- Patient registration and management
- Doctor scheduling and department organization
- Appointment booking and tracking
- Medical records and prescriptions
- Billing and payments
- Inventory management

The database follows normalization principles and includes proper constraints, relationships, and indexes for optimal performance.

## Database Schema
The database consists of 10 main tables:
1. `patients` - Stores patient demographic information
2. `doctors` - Contains doctor information and specialties
3. `staff` - Manages non-doctor staff members
4. `departments` - Organizes clinic departments
5. `doctor_schedules` - Tracks doctors' working hours
6. `appointments` - Manages patient bookings
7. `medical_records` - Stores patient health records
8. `prescriptions` - Tracks prescribed medications
9. `billing` - Handles financial transactions
10. `inventory` - Manages medical supplies

## ER Diagram
![Clinic Management System ERD](https://dbdiagram.io/d/Clinic-management-db-682485575b2fc4582f917ef3)  

## Setup Instructions

### Prerequisites
- MySQL Server (version 8.0 or higher recommended)
- MySQL Workbench or command-line client

### Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/clinic-management-db.git
   cd clinic-management-db