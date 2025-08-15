import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import '../pacientes/pacientes_list_page.dart';
import '../medicos/medicos_list_page.dart';
import '../citas/citas_list_page.dart';
import '../consultorios/consultorios_list_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final items = <_NavItem>[
      _NavItem('Inicio', Icons.dashboard, const DashboardPage()),
      _NavItem('Pacientes', Icons.person, const PacientesListPage(embedded: true)),
      _NavItem('Médicos', Icons.medical_services, const MedicosListPage(embedded: true)),
      _NavItem('Citas', Icons.event, const CitasListPage(embedded: true)),
      _NavItem('Consultorios', Icons.meeting_room, const ConsultoriosListPage(embedded: true)),
    ];
    final nav = items[_index];
    return Scaffold(
      body: Row(children: [
        _SideBar(items: items, selected: _index, onSelect: (i) => setState(() => _index = i)),
        Expanded(
          child: Container(
            color: const Color(0xFFF7F7F8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nav.label, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_subtitleFor(nav.label), style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(height: 28),
                      // Para Dashboard permitimos scroll si el contenido supera la pantalla.
                      if (nav.page is DashboardPage)
                        Expanded(
                          child: SingleChildScrollView(
                            child: nav.page,
                          ),
                        )
                      else
                        Expanded(child: nav.page),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }

  String _subtitleFor(String label) {
    switch (label) {
      case 'Inicio':
        return 'Resumen del sistema de citas médicas';
      case 'Pacientes':
        return 'Gestión de pacientes registrados';
      case 'Médicos':
        return 'Gestión de médicos registrados';
      case 'Citas':
        return 'Gestión de citas médicas';
      case 'Consultorios':
        return 'Gestión de consultorios disponibles';
      default:
        return '';
    }
  }
}

class _NavItem {
  final String label; final IconData icon; final Widget page;
  _NavItem(this.label, this.icon, this.page);
}

class _SideBar extends StatelessWidget {
  final List<_NavItem> items; final int selected; final ValueChanged<int> onSelect;
  const _SideBar({required this.items, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      color: const Color(0xFF008CDE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text('MedApp', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < items.length; i++) _SideBarButton(
            label: items[i].label,
            icon: items[i].icon,
            active: i == selected,
            onTap: () => onSelect(i),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('© 2025', style: TextStyle(color: Colors.white70, fontSize: 12)),
          )
        ],
      ),
    );
  }
}

class _SideBarButton extends StatelessWidget {
  final String label; final IconData icon; final bool active; final VoidCallback onTap;
  const _SideBarButton({required this.label, required this.icon, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final bg = active ? Colors.white : Colors.white.withOpacity(0.1);
    final fg = active ? const Color(0xFF008CDE) : Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(icon, color: fg, size: 20),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
            ])),
      ),
    );
  }
}
