import 'package:flutter/material.dart';
import 'dart:async';

class AppColors {
  static const Color greenPrimary = Color(0xFF0D5D33);
  static const Color greenAccent = Color(0xFF00C853);
  static const Color cream = Color(0xFFF1F4E0);
}

class CropRegisterScreen extends StatefulWidget {
  const CropRegisterScreen({super.key});

  @override
  State<CropRegisterScreen> createState() => _CropRegisterScreenState();
}

class _CropRegisterScreenState extends State<CropRegisterScreen> {
  int step = 1;
  Map<String, dynamic>? selectedCultivo;
  bool showSuccess = false;

  final Map<String, TextEditingController> controllers = {
    "area": TextEditingController(),
    "fecha": TextEditingController(text: "dd / mm / aaaa"),
    "ubicacion": TextEditingController(text: "Santa Ena, Hopelchén"),
  };

  final List<Map<String, dynamic>> cultivos = [
    {
      "id": "maiz",
      "nombre": "Maíz",
      "image": "assets/images/CUL - maiz.png",
      "color": const [Color(0xFFFBBF24), Color(0xFFEAB308)],
      "bgColor": const Color(0xFFFFFBEB),
      "borderColor": const Color(0xFFFEF3C7),
      "dias": "120 - 180 días",
      "season": "Primavera - Verano",
    },
    {
      "id": "tomate",
      "nombre": "Tomate",
      "image": "assets/images/CUL - tomate.png",
      "color": const [Color(0xFFF87171), Color(0xFFDC2626)],
      "bgColor": const Color(0xFFFEF2F2),
      "borderColor": const Color(0xFFFEE2E2),
      "dias": "90 - 120 días",
      "season": "Todo el año",
    },
    {
      "id": "sorgo",
      "nombre": "Sorgo",
      "image": "assets/images/CUL - sorgo.png",
      "color": const [Color(0xFFF97316), Color(0xFFEA580C)],
      "bgColor": const Color(0xFFFFF7ED),
      "borderColor": const Color(0xFFFFEDD5),
      "dias": "95 - 120 días",
      "season": "Verano - Otoño",
    },
    {
      "id": "trigo",
      "nombre": "Trigo",
      "image": "assets/images/CUL - trigo.png",
      "color": const [Color(0xFFD97706), Color(0xFFB45309)],
      "bgColor": const Color(0xFFFFFBEB),
      "borderColor": const Color(0xFFFDE68A),
      "dias": "110 - 150 días",
      "season": "Otoño - Invierno",
    },
    {
      "id": "zanahoria",
      "nombre": "Zanahoria",
      "image": "assets/images/CUL - zanahoria.png",
      "color": const [Color(0xFFF97316), Color(0xFFEA580C)],
      "bgColor": const Color(0xFFFFF7ED),
      "borderColor": const Color(0xFFFFEDD5),
      "dias": "90 - 120 días",
      "season": "Invierno - Primavera",
    },
    {
      "id": "soja",
      "nombre": "Soja",
      "image": "assets/images/CUL - soja.png",
      "color": const [Color(0xFF16A34A), Color(0xFF15803D)],
      "bgColor": const Color(0xFFF0FDF4),
      "borderColor": const Color(0xFFDCFCE7),
      "dias": "100 - 130 días",
      "season": "Primavera - Verano",
    },
  ];

  void handleSubmit() {
    setState(() => showSuccess = true);
    Timer(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: showSuccess
                    ? _buildSuccessView()
                    : (step == 1
                          ? _buildSelectCrop()
                          : (step == 2
                                ? _buildCropDetails()
                                : _buildConfirmStep())),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        color: AppColors.greenPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues( alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Registrar cultivo",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Nueva plantación",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          children: List.generate(3, (index) {
            int s = index + 1;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                decoration: BoxDecoration(
                  color: s <= step
                      ? Colors.white
                      : Colors.white.withValues( alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Cultivo",
              style: TextStyle(
                color: step >= 1 ? Colors.white : Colors.white60,
                fontSize: 12,
              ),
            ),
            Text(
              "Detalles",
              style: TextStyle(
                color: step >= 2 ? Colors.white : Colors.white60,
                fontSize: 12,
              ),
            ),
            Text(
              "Confirmar",
              style: TextStyle(
                color: step >= 3 ? Colors.white : Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectCrop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text(
          "¿Qué vas a sembrar?",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Selecciona el tipo de cultivo para tu nueva plantación",
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 25),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cultivos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (_, i) {
            final cultivo = cultivos[i];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCultivo = cultivo;
                  step = 2;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Stack(
                        children: [
                          Image.asset(
                            cultivo["image"],
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            height: 120,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.white],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      cultivo["nombre"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.greenPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          cultivo["dias"],
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Text(
                      cultivo["season"],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCropDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text(
          "Detalles de la plantación",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "Ingresa información de tu cultivo de ${selectedCultivo!["nombre"]}",
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFD54F),
            ), 
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(selectedCultivo!["icon"], color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCultivo!["nombre"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Ciclo: ${selectedCultivo!["dias"]} • ${selectedCultivo!["season"]}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => step = 1),
                child: const Text(
                  "Cambiar",
                  style: TextStyle(color: AppColors.greenAccent),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _buildInputField(
          Icons.map_outlined,
          "Área de siembra",
          "Superficie en hectáreas",
          controllers["area"]!,
          TextInputType.number,
          suffix: "ha",
        ),
        const SizedBox(height: 16),
        _buildInputField(
          Icons.calendar_today_outlined,
          "Fecha de siembra",
          "¿Cuándo plantaste o cuándo plantarás?",
          controllers["fecha"]!,
          TextInputType.datetime,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          Icons.location_on_outlined,
          "Ubicación",
          "Municipio o parcela",
          controllers["ubicacion"]!,
          TextInputType.text,
        ),

        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryButton(
                "Atrás",
                () => setState(() => step = 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPrimaryButton(
                "Continuar",
                () => setState(() => step = 3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildConfirmStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text(
          "Confirma tu registro",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Revisa que toda la información sea correcta",
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(selectedCultivo!["icon"], color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    selectedCultivo!["nombre"],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 30, color: Colors.black12),

              _buildConfirmRow(
                Icons.map_outlined,
                "Área",
                "${controllers["area"]!.text} hectáreas",
              ),
              _buildConfirmRow(
                Icons.calendar_today_outlined,
                "Fecha de siembra",
                controllers["fecha"]!.text,
              ),
              _buildConfirmRow(
                Icons.location_on_outlined,
                "Ubicación",
                controllers["ubicacion"]!.text,
              ),

              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildTimelineRow("Inicio", "10 nov"),
                    const SizedBox(height: 8),
                    _buildTimelineRow(
                      "Cosecha estimada",
                      "10 mar - 9 may 2027",
                      valueColor: AppColors.greenAccent,
                    ),
                    const Divider(color: Colors.black12, height: 20),
                    const Row(
                      children: [
                        Icon(Icons.label_outline, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Se programarán recordatorios automáticos de riego y fertilización",
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryButton(
                "Modificar",
                () => setState(() => step = 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPrimaryButton("Confirmar", handleSubmit),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: AppColors.greenPrimary,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: AppColors.greenPrimary.withValues( alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 70,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          "¡Registrado!",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.greenAccent,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Tu cultivo de ${selectedCultivo?["nombre"]} ha sido registrado exitosamente",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
        const SizedBox(height: 40),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 18, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              "Redirigiendo al seguimiento...",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField(
    IconData icon,
    String title,
    String subtitle,
    TextEditingController controller,
    TextInputType type, {
    String? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.greenPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E9D8)),
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType: type,
                    readOnly: type == TextInputType.datetime,
                    onTap: type == TextInputType.datetime
                        ? () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              setState(() {
                                controller.text =
                                    "${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}";
                              });
                            }
                          }
                        : null,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenPrimary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixText: suffix,
                      suffixStyle: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.greenPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.greenPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(
    String label,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.greenAccent,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        side: const BorderSide(color: Colors.black12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.greenPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
