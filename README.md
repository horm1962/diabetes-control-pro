# Controlando Mi Diabetes - Propuesta de App Móvil

## 1. Concepto del Proyecto
**Controlando Mi Diabetes** es una plataforma integral diseñada para transformar la gestión de la diabetes (Tipo 1, Tipo 2 y Gestacional). El enfoque principal es el empoderamiento del paciente mediante el análisis de datos, la educación continua y el fortalecimiento del vínculo médico-paciente.

---

## 2. Arquitectura Técnica Recomendada

### Stack de Tecnologías
*   **Mobile:** Flutter (Single codebase para iOS/Android con UI reactiva).
*   **Backend:** Node.js con NestJS (TypeScript) por su modularidad y escalabilidad.
*   **Base de Datos:** PostgreSQL para datos estructurados clínicos (integridad relacional).
*   **Autenticación:** Firebase Auth (Soporta MFA y OAuth2).
*   **Almacenamiento:** AWS S3 o Azure Blob Storage (Cifrado AES-256).
*   **Infraestructura:** Docker + Kubernetes para despliegue escalable.

### Seguridad y Cumplimiento
*   **Cifrado:** Datos en tránsito (TLS 1.3) y en reposo (AES-256).
*   **Privacidad:** Cumplimiento con estándares internacionales de protección de datos de salud (LOPDP Ecuador, GDPR).
*   **Consentimiento:** Sistema granular de permisos para compartir datos con profesionales de salud.

---

## 3. Estructura de la Base de Datos (Esquema Inicial)

| Entidad | Descripción |
| :--- | :--- |
| **Users** | Autenticación, rol (paciente/médico) y estado de cuenta. |
| **Profiles** | Datos específicos de salud: tipo de diabetes, peso, altura, rangos objetivo. |
| **GlucoseLogs** | Registros de glucemia con contexto (ayunas, post-prandial, etc.). |
| **Treatments** | Listado de medicamentos, tipos de insulina y dosis prescritas. |
| **MedicationLogs** | Registro histórico de tomas de medicación. |
| **VitalsLogs** | Presión arterial, frecuencia cardíaca y peso. |
| **NutritionLogs** | Carbohidratos, carga glucémica y fotos de alimentos. |
| **PhysicalActivity** | Tipo de ejercicio, duración e intensidad. |
| **Labs** | Resultados de laboratorio (HbA1c, perfil lipídico) y archivos adjuntos. |
| **Appointments** | Gestión de citas médicas y recordatorios. |

---

## 4. Diseño UX/UI (Wireframes)

### Pantallas Principales
1.  **Dashboard Principal:** 
    *   Resumen visual con gráfico de "Tiempo en Rango" (TIR).
    *   Indicadores de última medición y tendencia.
    *   Acceso rápido a registros mediante un botón flotante dinámico.
2.  **Módulo de Glucosa:**
    *   Gráficos interactivos diarios, semanales y mensuales.
    *   Identificación de patrones (Ej: hiperglucemias matutinas).
3.  **Módulo de Nutrición:**
    *   Calculadora de carbohidratos integrada con base de datos de alimentos.
    *   Registro fotográfico para facilitar la educación visual.
4.  **Panel del Médico:**
    *   Listado de pacientes asignados con alertas de riesgo basadas en algoritmos de tendencia.
    *   Generador de reportes clínicos automatizados en PDF.

---

## 5. Propuesta de Valor y Nombre
*   **Nombre sugerido:** `Controlando Mi Diabetes`
*   **Slogan:** "Tu salud, bajo control y en tus manos."
*   **Descripción para Tiendas:**
    > "La herramienta definitiva para la gestión de tu diabetes. Registra tus niveles de glucosa, medicación, alimentación y ejercicio en un solo lugar. Con Controlando Mi Diabetes, podrás entender tus patrones, prevenir complicaciones y mantener una comunicación fluida con tu médico. Diseñada para todos los tipos de diabetes, con una interfaz simple, segura y accesible."

---

## 6. Próximos Pasos de Desarrollo
1.  Prototipado de alta fidelidad en Figma.
2.  Configuración del entorno de desarrollo (Flutter + NestJS).
3.  Implementación del módulo de autenticación segura.
4.  Desarrollo del motor de registro de glucosa y visualización gráfica.
5.  Integración con Apple Health y Google Fit.
