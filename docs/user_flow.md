# Flujo de Usuario - Controlando Mi Diabetes

## 1. Onboarding y Registro (Paciente)
1.  **Pantalla de Bienvenida:** Introducción a las funcionalidades clave.
2.  **Registro de Cuenta:** Correo electrónico, contraseña, verificación de cuenta.
3.  **Configuración del Perfil (Wizard de Salud):**
    *   Selección del tipo de diabetes (T1, T2, Gestacional).
    *   Ingreso de datos básicos: Edad, Peso, Altura (Cálculo automático de IMC).
    *   Configuración de Rangos Objetivo (definidos por su médico o predeterminados).
    *   Configuración de Recordatorios (Medicamentos, Glucosa).
4.  **Dashboard:** Vista inicial del estado de salud actual.

---

## 2. Registro Diario de Glucosa (Flujo Crítico)
1.  **Acceso:** Botón central "+" en el Dashboard.
2.  **Entrada de Datos:**
    *   Selector numérico de nivel de glucosa.
    *   Categorización del contexto (Ayunas, Antes de comer, Después de comer, Antes de dormir).
    *   Notas adicionales (Ej: "Sentí mareos").
3.  **Confirmación y Feedback:**
    *   Si el valor está fuera de rango: Alerta inmediata con guía rápida de acción (Ej: instrucciones para hipoglucemia).
    *   Si el valor está en rango: Mensaje positivo y actualización del gráfico de tendencia.

---

## 3. Seguimiento de Nutrición y Medicación
1.  **Registro de Comida:** Búsqueda en base de datos de alimentos -> Selección de porción -> Cálculo de carbohidratos.
2.  **Registro de Medicación:** Notificación push de recordatorio -> Confirmación de dosis tomada (Dosis basal o bolo).
3.  **Análisis de Correlación:** Visualización en gráfico de cómo la comida y la insulina afectaron el nivel de glucosa en las últimas 4 horas.

---

## 4. Compartir con el Profesional de Salud (Flujo Médico)
1.  **Generación de Reporte:** Seleccionar periodo (7, 14, 30 días) -> Generar PDF con gráficos de tendencia y estadísticas clave (Promedio, TIR, HbA1c estimada).
2.  **Vinculación con Médico:** 
    *   El médico escanea el código QR del paciente o el paciente ingresa el código del médico.
    *   El médico recibe acceso a los datos históricos en tiempo real a través de su propio panel de control.

---

## 5. Gestión de Emergencias
1.  **Acceso Rápido:** Botón de "Emergencia" siempre visible o accesible en 1 paso.
2.  **Instrucciones Paso a Paso:** Qué hacer en caso de hipoglucemia severa o cetoacidosis.
3.  **Botón de Pánico:** Llamada directa al contacto de emergencia configurado o servicios de emergencia locales.
