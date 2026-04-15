# Guía para Ejecutar y Probar "Controlando Mi Diabetes"

Para poner en marcha la aplicación en un entorno de desarrollo, sigue estos pasos:

## 1. Requisitos Previos
Asegúrate de tener instalados:
- **Node.js** (v18 o superior)
- **Flutter SDK** (v3.10 o superior)
- **PostgreSQL** (Iniciado con una base de datos llamada `diabetes_db`)
- **VS Code** con extensiones de Flutter y NestJS (Recomendado)

---

## 2. Preparación del Backend (API)
El backend maneja la autenticación y el almacenamiento de datos clínicos.

1. Abre una terminal en la carpeta `api`:
   ```bash
   cd api
   ```
2. Instala las dependencias:
   ```bash
   npm install
   ```
3. Verifica el archivo `.env` (ya creado con valores por defecto):
   - Asegúrate de que el usuario y contraseña de PostgreSQL coincidan con tu instalación local.
4. Inicia el servidor en modo desarrollo:
   ```bash
   npm run start:dev
   ```
   *El servidor estará disponible en `http://localhost:3000`.*

---

## 3. Preparación del Frontend (App Móvil)
La aplicación Flutter se conecta al API para gestionar los datos.

1. Abre una terminal en la carpeta `app`:
   ```bash
   cd app
   ```
2. Descarga los paquetes necesarios:
   ```bash
   flutter pub get
   ```
3. Ejecuta la aplicación:
   - **Para Windows (Prueba rápida):**
     ```bash
     flutter run -d windows
     ```
   - **Para Android/iOS:**
     - Conecta un dispositivo físico o inicia un simulador.
     - Ejecuta: `flutter run`

### **Nota para Android Emulator:**
Si usas el emulador de Android, cambia `localhost` por `10.0.2.2` en el archivo `app/lib/services/auth_service.dart` y otros servicios para que la app pueda comunicarse con el backend.

---

## 4. Pruebas de Usuario (Flujo de Trabajo)

### **Prueba de Paciente:**
1. Regístrate en la pantalla de Login con un email y contraseña.
2. Una vez en el Dashboard, usa el botón **"+"** para registrar un nivel de glucosa (ej: 120 mg/dL).
3. Entra en el módulo de **Nutrición** y registra una comida.
4. Configura un **Recordatorio** para ver si las notificaciones locales se activan correctamente.

### **Prueba de Médico:**
1. (Opcional) Cambia manualmente el rol de un usuario en la base de datos a `'doctor'`.
2. Inicia sesión con esa cuenta.
3. Deberías ver el **Panel del Médico** con la lista de pacientes registrados.

---

## 5. Herramientas Útiles para Pruebas
- **Postman/Insomnia:** Para probar los endpoints del API directamente.
- **DBeaver/pgAdmin:** Para visualizar las tablas y registros en PostgreSQL.
- **Flutter DevTools:** Para inspeccionar el rendimiento y la UI de la app.

---

## 6. Comandos de Validación Rápida

Ejecuta estos comandos antes de continuar con nuevas funcionalidades:

### Frontend (`app`)
```bash
cd app
flutter analyze
flutter test
```

### Backend (`api`)
```bash
cd api
npm run build
npm test
```
