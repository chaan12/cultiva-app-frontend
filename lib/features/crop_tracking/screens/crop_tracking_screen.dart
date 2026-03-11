import 'package:flutter/material.dart';

class CropTrackingScreen extends StatefulWidget {
  const CropTrackingScreen({super.key});

  @override
  State<CropTrackingScreen> createState() => _CropTrackingScreenState();
}

class _CropTrackingScreenState extends State<CropTrackingScreen> {
  bool notifications = true;
  String activeTab =
      "timeline"; // Por defecto en timeline para visualizar los cambios

  final Map<String, dynamic> cultivo = {
    "nombre": "Maíz",
    "area": "2.5 ha",
    "diasDesdeSiembra": 23,
    "etapaActual": "Crecimiento vegetativo",
    "progreso": 19,
    "totalDias": 120,
    "diasCosecha": 97,
  };

  final List<Map<String, dynamic>> upcomingEvents = [
    {
      "task": "Aplicar fertilizante NPK",
      "date": "10 Mayo",
      "daysUntil": 2,
      "priority": "high",
      "icon": Icons.water_drop,
      "description": "Fase crítica de nutrición",
    },
    {
      "task": "Inspección de plagas",
      "date": "12 Mayo",
      "daysUntil": 4,
      "priority": "medium",
      "icon": Icons.bug_report,
      "description": "Monitoreo preventivo",
    },
    {
      "task": "Riego profundo",
      "date": "14 Mayo",
      "daysUntil": 6,
      "priority": "medium",
      "icon": Icons.water_drop,
      "description": "Mantener humedad del suelo",
    },
  ];

  final List<Map<String, dynamic>> timelineStages = [
    {
      "name": "Siembra",
      "date": "15 Abril 2026",
      "description": "Plantación inicial",
      "completed": true,
      "icon": Icons.eco,
    },
    {
      "name": "Germinación",
      "date": "22 Abril 2026",
      "description": "Primeras plántulas visibles",
      "completed": true,
      "icon": Icons.eco_outlined,
    },
    {
      "name": "Crecimiento vegetativo",
      "date": "5 Mayo 2026",
      "description": "Desarrollo de hojas y tallos",
      "current": true,
      "daysRemaining": 7,
      "icon": Icons.trending_up,
    },
    {
      "name": "Floración",
      "date": "25 Mayo 2026",
      "description": "Aparición de flores",
      "completed": false,
      "icon": Icons.wb_sunny_outlined,
    },
    {
      "name": "Fructificación",
      "date": "10 Junio 2026",
      "description": "Formación de frutos",
      "completed": false,
      "icon": Icons.spa_outlined,
    },
    {
      "name": "Cosecha",
      "date": "15 Julio 2026",
      "description": "Momento óptimo de recolección",
      "completed": false,
      "icon": Icons.check_circle_outline,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4E0), // Fondo crema de la imagen
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildNotificationToggle(),
                  const SizedBox(height: 20),
                  _buildTabSelector(),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: activeTab == "events"
                        ? _buildEventsList()
                        : _buildTimeline(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF0D5D33),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 10),
          Text(
            cultivo["nombre"],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${cultivo["area"]} • Día ${cultivo["diasDesdeSiembra"]}/${cultivo["totalDias"]}",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cultivo["etapaActual"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${cultivo["progreso"]}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: cultivo["progreso"] / 100,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${cultivo["diasCosecha"]} días hasta cosecha estimada",
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: notifications
                ? const Color(0xFFE8F5E9)
                : Colors.grey[100],
            child: Icon(
              notifications
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: notifications ? const Color(0xFF0D5D33) : Colors.grey,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Notificaciones",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  notifications ? "Alertas activas" : "Alertas desactivadas",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: notifications,
            onChanged: (v) => setState(() => notifications = v),
            activeThumbColor: const Color(0xFF00C853),
            activeTrackColor: const Color(0xFF00C853).withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _tabButton("events", Icons.bolt, "Eventos"),
          _tabButton("timeline", Icons.auto_graph, "Ciclo"),
        ],
      ),
    );
  }

  Widget _tabButton(String id, IconData icon, String label) {
    bool isSelected = activeTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D5D33) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return Column(
      key: const ValueKey("events_list"),
      children: upcomingEvents.map((event) => _eventCard(event)).toList(),
    );
  }

  Widget _eventCard(Map<String, dynamic> event) {
    Color priorityColor = event["priority"] == "high"
        ? Colors.redAccent
        : Colors.amber[700]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: priorityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(event["icon"], color: priorityColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event["task"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    event["description"],
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "En ${event["daysUntil"]} días",
                    style: TextStyle(
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      key: const ValueKey("timeline_view"),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Línea de tiempo del cultivo",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D5D33),
            ),
          ),
          const SizedBox(height: 25),
          ...timelineStages.asMap().entries.map(
            (entry) => _timelineItem(
              entry.value,
              entry.key == timelineStages.length - 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(Map<String, dynamic> stage, bool isLast) {
    bool isCompleted = stage["completed"] ?? false;
    bool isCurrent = stage["current"] ?? false;

    // Colores exactos de la imagen
    Color iconBgColor = isCompleted
        ? const Color(0xFF7CB342) // Verde claro para completados
        : (isCurrent
              ? const Color(0xFF33691E)
              : Colors.white); // Verde oscuro para actual

    Color iconColor = isCurrent || isCompleted ? Colors.white : Colors.grey;
    Color connectorColor = isCompleted
        ? const Color(0xFF7CB342)
        : Colors.grey.shade200;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: !isCurrent && !isCompleted
                      ? Border.all(color: Colors.grey.shade200)
                      : null,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(stage["icon"], color: iconColor, size: 24),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 4,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: connectorColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stage["name"],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCurrent || isCompleted
                            ? const Color(0xFF2E7D32)
                            : Colors.black54,
                      ),
                    ),
                    if (isCurrent && stage["daysRemaining"] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF2D4B2D,
                          ), // Color oscuro para el badge
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "${stage["daysRemaining"]}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              "días",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Text(
                  stage["description"] ?? "",
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stage["date"],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 30), // Espacio entre items
              ],
            ),
          ),
        ],
      ),
    );
  }
}
