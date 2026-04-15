-- Esquema de base de datos para Controlando Mi Diabetes

-- 1. Usuarios y Perfiles
CREATE TABLE Users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) CHECK (role IN ('patient', 'doctor', 'admin')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Profiles (
    user_id UUID PRIMARY KEY REFERENCES Users(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    diabetes_type VARCHAR(50) CHECK (diabetes_type IN ('type1', 'type2', 'gestational')),
    birth_date DATE,
    weight_kg DECIMAL(5, 2),
    height_cm DECIMAL(5, 2),
    target_glucose_low DECIMAL(5, 2),
    target_glucose_high DECIMAL(5, 2),
    insulin_type VARCHAR(100),
    medications TEXT,
    allergies TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Registros de Salud
CREATE TABLE GlucoseLogs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES Users(id) ON DELETE CASCADE,
    value DECIMAL(5, 2) NOT NULL, -- mg/dL
    context VARCHAR(100) CHECK (context IN ('fasting', 'pre_meal', 'post_meal', 'before_bed', 'other')),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE TABLE MedicationLogs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES Users(id) ON DELETE CASCADE,
    medication_name VARCHAR(255) NOT NULL,
    dosage VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_insulin BOOLEAN DEFAULT FALSE
);

CREATE TABLE VitalsLogs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES Users(id) ON DELETE CASCADE,
    systolic INT,
    diastolic INT,
    heart_rate INT,
    weight DECIMAL(5, 2),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Nutrición y Actividad
CREATE TABLE NutritionLogs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES Users(id) ON DELETE CASCADE,
    meal_type VARCHAR(50) CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    carbs_g DECIMAL(5, 2),
    protein_g DECIMAL(5, 2),
    fat_g DECIMAL(5, 2),
    calories INT,
    glycemic_index DECIMAL(5, 2),
    photo_url TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ActivityLogs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES Users(id) ON DELETE CASCADE,
    activity_type VARCHAR(100),
    duration_minutes INT,
    intensity VARCHAR(50) CHECK (intensity IN ('low', 'medium', 'high')),
    calories_burned INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Gestión Médica y Citas
CREATE TABLE Appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES Users(id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES Users(id),
    appointment_date TIMESTAMP NOT NULL,
    location TEXT,
    status VARCHAR(50) CHECK (status IN ('scheduled', 'completed', 'cancelled', 'rescheduled')),
    notes TEXT
);

CREATE TABLE PatientDoctorLink (
    patient_id UUID REFERENCES Users(id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES Users(id) ON DELETE CASCADE,
    access_granted BOOLEAN DEFAULT TRUE,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (patient_id, doctor_id)
);

-- 5. Laboratorios
CREATE TABLE LabResults (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES Users(id) ON DELETE CASCADE,
    test_name VARCHAR(255) NOT NULL, -- e.g., HbA1c
    value DECIMAL(10, 2),
    unit VARCHAR(50),
    file_url TEXT,
    test_date DATE,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
