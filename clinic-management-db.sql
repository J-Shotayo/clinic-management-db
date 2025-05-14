-- Clinic Management System Database
-- Created by Shoatyo Jubril

-- Create database
CREATE DATABASE IF NOT EXISTS clinic_management;
USE clinic_management;

-- Patients table - stores patient information
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    address TEXT,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE,
    blood_type ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    registration_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uc_patient_identity UNIQUE (first_name, last_name, date_of_birth, phone)
) COMMENT 'Stores patient demographic information';

-- Doctors table - stores doctor information
CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    license_number VARCHAR(50) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
) COMMENT 'Contains doctor information and specialties';

-- Staff table - clinic staff information
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role ENUM('Nurse', 'Receptionist', 'Administrator', 'Technician') NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE,
    hire_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
) COMMENT 'Contains non-doctor staff information';

-- Departments table - clinic departments
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100),
    head_doctor_id INT,
    CONSTRAINT fk_department_head FOREIGN KEY (head_doctor_id) 
        REFERENCES doctors(doctor_id) ON DELETE SET NULL
) COMMENT 'Clinic departments and their locations';

-- Doctor Departments relationship (M-M)
CREATE TABLE doctor_departments (
    doctor_id INT NOT NULL,
    department_id INT NOT NULL,
    PRIMARY KEY (doctor_id, department_id),
    CONSTRAINT fk_dd_doctor FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    CONSTRAINT fk_dd_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE CASCADE
) COMMENT 'Junction table for doctor-department many-to-many relationship';

-- Doctor Schedules table - working hours
CREATE TABLE doctor_schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_recurring BOOLEAN DEFAULT TRUE,
    effective_from DATE NOT NULL,
    effective_to DATE,
    CONSTRAINT fk_schedule_doctor FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    CONSTRAINT chk_schedule_time CHECK (end_time > start_time),
    CONSTRAINT chk_effective_date CHECK (effective_to IS NULL OR effective_to >= effective_from)
) COMMENT 'Stores doctors working schedules';

-- Appointments table - patient appointments
CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    duration_minutes INT NOT NULL DEFAULT 30,
    status ENUM('Scheduled', 'Completed', 'Cancelled', 'No-Show') DEFAULT 'Scheduled',
    reason TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    CONSTRAINT chk_duration CHECK (duration_minutes BETWEEN 15 AND 120)
) COMMENT 'Tracks all patient appointments';

-- Medical Records table - patient health records
CREATE TABLE medical_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_id INT,
    visit_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diagnosis TEXT,
    treatment TEXT,
    notes TEXT,
    CONSTRAINT fk_record_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_record_doctor FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    CONSTRAINT fk_record_appointment FOREIGN KEY (appointment_id) 
        REFERENCES appointments(appointment_id) ON DELETE SET NULL
) COMMENT 'Contains patient medical history and visit records';

-- Prescriptions table - prescribed medications
CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id INT NOT NULL,
    medication_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    duration VARCHAR(50) NOT NULL,
    instructions TEXT,
    prescribed_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prescription_record FOREIGN KEY (record_id) 
        REFERENCES medical_records(record_id) ON DELETE CASCADE
) COMMENT 'Stores prescribed medications for patients';

-- Billing table - financial transactions
CREATE TABLE billing (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT,
    total_amount DECIMAL(10,2) NOT NULL,
    paid_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    balance DECIMAL(10,2) GENERATED ALWAYS AS (total_amount - paid_amount) STORED,
    billing_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    status ENUM('Pending', 'Partially Paid', 'Paid', 'Overdue') DEFAULT 'Pending',
    payment_method ENUM('Cash', 'Credit Card', 'Insurance', 'Bank Transfer'),
    CONSTRAINT fk_billing_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_billing_appointment FOREIGN KEY (appointment_id) 
        REFERENCES appointments(appointment_id) ON DELETE SET NULL,
    CONSTRAINT chk_amounts CHECK (paid_amount <= total_amount AND total_amount > 0)
) COMMENT 'Manages clinic billing and payments';

-- Inventory table - medical supplies
CREATE TABLE inventory (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 5,
    unit_price DECIMAL(10,2) NOT NULL,
    supplier VARCHAR(100),
    last_restocked DATE
) COMMENT 'Tracks clinic medical supplies inventory';

-- Create indexes for performance
CREATE INDEX idx_patient_name ON patients(last_name, first_name);
CREATE INDEX idx_doctor_name ON doctors(last_name, first_name);
CREATE INDEX idx_appointment_dates ON appointments(scheduled_date, scheduled_time);
CREATE INDEX idx_medical_record_patient ON medical_records(patient_id);
CREATE INDEX idx_billing_status ON billing(status);