import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// --- MODELOS DE DATOS ---
class WeatherData {
  final String dia;
  final double valor;
  WeatherData(this.dia, this.valor);
}

class WeatherSource {
  final String id;
  final String name;
  final String description;
  bool favorite;
  bool active;
  final int reliability;
  final Map<String, String> data;
  final List<String> alerts;

  WeatherSource({
    required this.id,
    required this.name,
    required this.description,
    this.favorite = false,
    this.active = true,
    required this.reliability,
    required this.data,
    required this.alerts,
  });
}

class ClimaScreen extends StatefulWidget {
  const ClimaScreen({super.key});

  @override
  State<ClimaScreen> createState() => _ClimaScreenState();
}

class _ClimaScreenState extends State<ClimaScreen> {
  int currentIndex = 3; // Index 3 para "Clima"

  // Datos de las gráficas
  final List<WeatherData> temperatureData = [
    WeatherData('Lun', 28),
    WeatherData('Mar', 30),
    WeatherData('Mié', 29),
    WeatherData('Jue', 31),
    WeatherData('Vie', 32),
    WeatherData('Sáb', 30),
    WeatherData('Dom', 28),
  ];

  final List<WeatherData> rainfallData = [
    WeatherData('Lun', 5),
    WeatherData('Mar', 12),
    WeatherData('Mié', 8),
    WeatherData('Jue', 18),
    WeatherData('Vie', 22),
    WeatherData('Sáb', 15),
    WeatherData('Dom', 10),
  ];

  List<WeatherSource> sources = [
    WeatherSource(
      id: 'smn',
      name: 'SMN México',
      description: 'Servicio Meteorológico Nacional',
      favorite: true,
      reliability: 95,
      data: {
        'temperature': '28°C',
        'humidity': '75%',
        'rainProbability': '65%',
        'windSpeed': '12 km/h',
        'uvIndex': 'Alto',
        'visibility': '10 km',
      },
      alerts: ['Lluvias intensas próximas 72h'],
    ),
    WeatherSource(
      id: 'noaa',
      name: 'NOAA',
      description: 'National Oceanic and Atmospheric Administration',
      favorite: true,
      reliability: 92,
      data: {
        'temperature': '29°C',
        'humidity': '73%',
        'rainProbability': '60%',
        'windSpeed': '15 km/h',
        'uvIndex': 'Muy alto',
        'visibility': '12 km',
      },
      alerts: ['Temporada de lluvias activa'],
    ),
    WeatherSource(
      id: 'conagua',
      name: 'CONAGUA',
      description: 'Comisión Nacional del Agua',
      reliability: 88,
      data: {
        'temperature': '28°C',
        'humidity': '76%',
        'rainProbability': '70%',
        'windSpeed': '11 km/h',
      },
      alerts: ['Monitoreo de precipitación'],
    ),
    WeatherSource(
      id: 'wunderground',
      name: 'Weather Underground',
      description: 'Red de estaciones meteorológicas',
      active: false,
      reliability: 85,
      data: {
        'temperature': '27°C',
        'humidity': '74%',
        'rainProbability': '58%',
        'windSpeed': '13 km/h',
        'visibility': '9 km',
      },
      alerts: [],
    ),
  ];

  void toggleFavorite(String id) {
    setState(() {
      final index = sources.indexWhere((s) => s.id == id);
      if (index != -1) {
        sources[index].favorite = !sources[index].favorite;
      }
    });
  }

  void toggleActive(String id) {
    setState(() {
      final index = sources.indexWhere((s) => s.id == id);
      if (index != -1) {
        sources[index].active = !sources[index].active;
      }
    });
  }

  List<WeatherSource> get sortedSources {
    List<WeatherSource> sorted = List.from(sources);

    sorted.sort((a, b) {
      if (a.favorite && !b.favorite) return -1;
      if (!a.favorite && b.favorite) return 1;
      return b.reliability.compareTo(a.reliability);
    });

    return sorted;
  }

  List<WeatherSource> get activeSources {
    return sortedSources.where((s) => s.active).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4E0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildAlertSection(),
                  const SizedBox(height: 20),
                  _buildChartCard(
                    "Temperatura (7 días)",
                    Icons.thermostat,
                    Colors.blue,
                    _tempChart(),
                  ),
                  const SizedBox(height: 20),
                  _buildChartCard(
                    "Precipitación (mm)",
                    Icons.cloud_queue,
                    Colors.green,
                    _rainChart(),
                  ),
                  const SizedBox(height: 20),
                  _buildSourcesList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE LA INTERFAZ ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          ),
          const Text(
            "Clima Premium",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Dashboard meteorológico profesional",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 25),
          _buildMainWeatherCard(),
        ],
      ),
    );
  }

  Widget _buildMainWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues( alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Condiciones actuales",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "28°C",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Parcialmente nublado",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              const Icon(Icons.cloud_outlined, color: Colors.white, size: 80),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _headerInfo(Icons.air, "12 km/h", "Viento"),
              _headerInfo(Icons.water_drop_outlined, "75%", "Humedad"),
              _headerInfo(Icons.umbrella_outlined, "65%", "Lluvia"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerInfo(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAlertSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              "Alertas activas",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orangeAccent),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.priority_high, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Lluvias intensas",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    Text(
                      "Próximos 3 días - Acumulado: 40-60mm",
                      style: TextStyle(color: Color(0xFFE65100), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(
    String title,
    IconData icon,
    Color color,
    Widget chart,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues( alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues( alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "7 DÍAS",
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  // --- LÓGICA DE GRÁFICAS (FL_CHART) ---

  Widget _tempChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.black12, strokeWidth: 1),
        ),
        titlesData: _titlesData(),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: temperatureData
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.valor))
                .toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues( alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rainChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: _titlesData(),
        borderData: FlBorderData(show: false),
        barGroups: rainfallData
            .asMap()
            .entries
            .map(
              (e) => BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.valor,
                    color: Colors.green,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  FlTitlesData _titlesData() {
    return FlTitlesData(
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
            return Text(
              days[value.toInt() % 7],
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSourcesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Fuentes meteorológicas",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues( alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${activeSources.length} activas",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ...sortedSources.map((s) => _sourceCard(s)),
      ],
    );
  }

  Widget _sourceCard(WeatherSource source) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: source.favorite
            ? Border.all(color: Colors.amber, width: 2)
            : Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: source.favorite
                  ? Colors.amber.withValues( alpha: 0.08)
                  : Colors.grey.withValues( alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            source.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => toggleFavorite(source.id),
                      icon: Icon(
                        source.favorite ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: source.reliability / 100,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(
                          source.reliability >= 90
                              ? Colors.green
                              : source.reliability >= 80
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${source.reliability}% confiable",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.9,
              children: source.data.entries.map((e) {
                IconData icon = Icons.info;
                Color color = Colors.blue;
                String label = e.key;

                switch (e.key) {
                  case 'temperature':
                    icon = Icons.thermostat;
                    color = Colors.blue;
                    label = "Temp";
                    break;
                  case 'humidity':
                    icon = Icons.water_drop;
                    color = Colors.green;
                    label = "Humedad";
                    break;
                  case 'rainProbability':
                    icon = Icons.grain;
                    color = Colors.blue;
                    label = "Lluvia";
                    break;
                  case 'windSpeed':
                    icon = Icons.air;
                    color = Colors.teal;
                    label = "Viento";
                    break;
                  case 'uvIndex':
                    icon = Icons.wb_sunny;
                    color = Colors.deepOrange;
                    label = "UV";
                    break;
                  case 'visibility':
                    icon = Icons.remove_red_eye;
                    color = Colors.green;
                    label = "Visib.";
                    break;
                }

                return Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues( alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: color.withValues( alpha: 0.35)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 22, color: color),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        e.value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          if (source.alerts.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues( alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: source.alerts.map((alert) {
                  return Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 16, color: Colors.orange),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          alert,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.withValues( alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  source.active ? "Fuente activa" : "Fuente desactivada",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: source.active,
                  onChanged: (_) => toggleActive(source.id),
                  activeColor: Colors.blue,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
