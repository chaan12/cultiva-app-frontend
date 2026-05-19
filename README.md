# 🌱 Cultiva+

<p align="center">
  <img src="assets/logos/cultiva_logo.png" width="180" alt="Cultiva+ Logo"/>
</p>

<p align="center">
  <b>Cultivando decisiones inteligentes.</b><br>
  Tecnología agrícola moderna para productores del presente y del futuro.
</p>

---

## 🚜 ¿Qué es Cultiva+?

**Cultiva+** es una plataforma móvil agrícola diseñada para ayudar a productores a tomar mejores decisiones mediante:

- 🌦️ Información climática
- 📍 Seguimiento de cultivos
- 🌱 Registro agrícola
- 📈 Monitoreo inteligente
- ⚠️ Alertas y riesgos
- 🧠 Recomendaciones inteligentes
- 📶 Modo offline
- 🗓️ Cabañuelas y predicciones

La aplicación busca unir la experiencia tradicional del campo con herramientas tecnológicas modernas para optimizar la producción agrícola.

---

# ✨ Características principales

## 🌦️ Clima inteligente

Consulta información meteorológica relevante para tus cultivos:

- Temperatura
- Humedad
- Probabilidad de lluvia
- Velocidad del viento
- Riesgos climáticos

> [!TIP]
> La información climática ayuda a planificar riego, fertilización y aplicaciones agrícolas.

---

## 🌱 Registro de cultivos

Administra fácilmente todos tus cultivos:

- Tipo de cultivo
- Fecha de siembra
- Área sembrada
- Ubicación
- Estado del cultivo

### Cultivos soportados

- 🌽 Maíz
- 🌱 Soya
- 🌾 Sorgo
- Y más próximamente...

---

## 📊 Seguimiento y monitoreo

Lleva control del crecimiento y evolución de tus cultivos mediante:

- Eventos importantes
- Hitos de crecimiento
- Seguimiento visual
- Estado actual
- Recomendaciones automáticas

---

## 📶 Modo Offline

Cultiva+ puede funcionar incluso sin conexión.

> [!NOTE]
> Pensado especialmente para zonas rurales con conectividad limitada.

---

## 🧠 Recomendaciones inteligentes

La plataforma analiza:

- Condiciones climáticas
- Tipo de cultivo
- Etapa de crecimiento
- Riesgos agrícolas

Para generar recomendaciones útiles al productor.

---

# 🎨 Diseño y experiencia

Cultiva+ utiliza un diseño:

- Moderno
- Minimalista
- Agrícola-tech
- Visualmente limpio
- Optimizado para dispositivos móviles

La interfaz busca transmitir:

✅ Confianza  
✅ Tecnología  
✅ Simplicidad  
✅ Profesionalismo

---

# 🛠️ Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| Flutter | Desarrollo móvil multiplataforma |
| Dart | Lenguaje principal |
| SQLite | Base de datos local |
| APIs Climáticas | Datos meteorológicos |
| Docker | Contenedores y despliegue |
| PHP (Backend) | Servicios y lógica de servidor |

---

# 🔐 Configuración de entorno

Cultiva+ usa un sistema centralizado de variables de entorno para separar configuración, URLs, endpoints y futuras llaves privadas del código fuente.

## Archivos

- `.env.example`: plantilla versionada para desarrolladores.
- `.env`: configuración local real. Este archivo está ignorado por Git y no debe compartirse.

## Configuración local

1. Copia la plantilla:

```bash
cp .env.example .env
```

2. Ajusta los valores de `.env` según el entorno local, staging o producción.

3. Ejecuta la app normalmente:

```bash
flutter pub get
flutter run
```

## Variables requeridas

| Variable | Uso |
|---|---|
| `CULTIVA_ENV` | Entorno activo: `development`, `staging` o `production` |
| `CULTIVA_WEATHER_API_HOST` | Host del proveedor meteorológico |
| `CULTIVA_HISTORICAL_WEATHER_API_HOST` | Host del proveedor histórico |
| `CULTIVA_HTTP_TIMEOUT_SECONDS` | Tiempo máximo de espera para peticiones HTTP |
| `CULTIVA_WEATHER_ENDPOINT_NOAA_GFS` | Endpoint del modelo NOAA GFS |
| `CULTIVA_WEATHER_ENDPOINT_ECMWF` | Endpoint del modelo ECMWF |
| `CULTIVA_WEATHER_ENDPOINT_GEM` | Endpoint del modelo GEM |
| `CULTIVA_WEATHER_ENDPOINT_METEOFRANCE` | Endpoint del modelo Meteo-France |
| `CULTIVA_WEATHER_ENDPOINT_JMA` | Endpoint del modelo JMA |
| `CULTIVA_CANUELA_ARCHIVE_PATH` | Endpoint histórico para cabañuelas |
| `CULTIVA_MAPS_HOST` | Host externo para abrir mapas |
| `CULTIVA_MAPS_SEARCH_PATH` | Ruta para búsqueda de mapas |
| `CULTIVA_MAPS_DIRECTIONS_PATH` | Ruta para direcciones de mapas |

## Variables opcionales

| Variable | Uso |
|---|---|
| `CULTIVA_WEATHER_API_KEY` | Llave futura para proveedor meteorológico |
| `CULTIVA_MAPS_API_KEY` | Llave futura para mapas |
| `CULTIVA_ANALYTICS_KEY` | Llave futura para analítica |

## Buenas prácticas

- Nunca subas `.env` ni archivos con secretos reales.
- Mantén `.env.example` sin credenciales reales.
- No guardes secretos de backend de alto privilegio dentro de una app móvil; usa un backend/proxy seguro para credenciales que no deban llegar al dispositivo.
- Para CI/CD, inyecta variables con `--dart-define` o genera `.env` desde el gestor seguro del proveedor.
- No imprimas variables de entorno, tokens, llaves ni respuestas crudas de APIs en logs.
- Usa `AppConfig` como única capa de lectura de configuración; no accedas a `dotenv` directamente desde widgets o servicios.

---

# 📱 Pantallas principales

- 🏠 Dashboard
- 🌱 Registro de cultivos
- 📚 Catálogo de cultivos
- 📈 Seguimiento agrícola
- 🌦️ Clima
- 🗓️ Cabañuelas
- 🎯 Próximos hitos

---

# 💡 Objetivo del proyecto

Ayudar a productores agrícolas a:

- Reducir riesgos
- Tomar mejores decisiones
- Optimizar recursos
- Mejorar productividad
- Modernizar procesos agrícolas

---

# 💰 Modelo de negocio

## Distribuidores agrícolas

Licencias empresariales para distribuidores y empresas agrícolas.

## Productores

Acceso gratuito mediante alianzas estratégicas.

## Premium

Funciones avanzadas y herramientas exclusivas.

---

# 👨‍💻 Equipo

| Integrantes |
|---|
| Eduardo Chan |
| Fernando Arcos |
| Victor Escalante |
| José Villamil |

---

# 🚀 Visión

Convertirnos en una de las principales plataformas tecnológicas agrícolas en México y Latinoamérica.

---

# 📌 Estado del proyecto

> [!IMPORTANT]
> Cultiva+ actualmente se encuentra en desarrollo activo.

---

# 📬 Contacto

📧 chanxortiz@gmail.com

🌐 próximamente...

---

<p align="center">
  Hecho con 🌱 para el campo mexicano.
</p>
