import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/firestore_service.dart';
import 'register_medicamentos.dart';
import 'package:circular_menu/circular_menu.dart';

class MedicamentosPage extends StatefulWidget {
  final String idosoId;
  final String apelido;

  const MedicamentosPage({
    super.key,
    required this.idosoId,
    required this.apelido,
  });

  @override
  State<MedicamentosPage> createState() => _MedicamentosPageState();
}

class _MedicamentosPageState extends State<MedicamentosPage> {
  final _firestoreService = FirestoreService();
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  bool _calendarExpanded = true;
  Map<String, dynamic>? idosoData;
  bool isLoading = false;
  // filterMode: true = show by Date (only active meds on selected date)
  // false = show All (all meds), but status is evaluated against the selected date
  bool filterByDate = false; // false = Todos, true = Data

  @override
  void initState() {
    super.initState();
    // Inicializa a localização do intl para pt_BR (meses/nome dos dias)
    initializeDateFormatting('pt_BR');
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    fetchIdoso();
  }

  Future<void> fetchIdoso() async {
    setState(() {
      // Carregamento inicial controlado pelos builders, evitar overlay duplicado
      isLoading = false;
    });
    final doc = await FirebaseFirestore.instance
        .collection('idoso')
        .doc(widget.idosoId)
        .get();
    setState(() {
      idosoData = doc.data();
      isLoading = false;
    });
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    DateTime dt;
    if (date is Timestamp) {
      dt = date.toDate();
    } else if (date is DateTime) {
      dt = date;
    } else {
      return '';
    }
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  bool _isMedicamentoActive(Map<String, dynamic> data) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    if (data['dataInicio'] == null) return false;

    DateTime dataInicio;
    if (data['dataInicio'] is Timestamp) {
      dataInicio = (data['dataInicio'] as Timestamp).toDate();
    } else if (data['dataInicio'] is DateTime) {
      dataInicio = data['dataInicio'] as DateTime;
    } else {
      return false;
    }

    dataInicio = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);

    if (dataInicio.isAfter(today)) return false;

    if (data['dataFim'] != null) {
      DateTime dataFim;
      if (data['dataFim'] is Timestamp) {
        dataFim = (data['dataFim'] as Timestamp).toDate();
      } else if (data['dataFim'] is DateTime) {
        dataFim = data['dataFim'] as DateTime;
      } else {
        return true;
      }
      dataFim = DateTime(dataFim.year, dataFim.month, dataFim.day);
      if (today.isAfter(dataFim)) return false;
    }

    return true;
  }

  int _getDaysRemaining(Map<String, dynamic> data) {
    if (data['dataFim'] == null) return 999;

    DateTime dataFim;
    if (data['dataFim'] is Timestamp) {
      dataFim = (data['dataFim'] as Timestamp).toDate();
    } else if (data['dataFim'] is DateTime) {
      dataFim = data['dataFim'] as DateTime;
    } else {
      return 999;
    }

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    dataFim = DateTime(dataFim.year, dataFim.month, dataFim.day);

    return dataFim.difference(today).inDays;
  }

  // Days remaining relative to a given date (used to show days remaining based on the calendar selection)
  int _getDaysRemainingOnDate(Map<String, dynamic> data, DateTime date) {
    if (data['dataFim'] == null) return 999;

    DateTime dataFim;
    if (data['dataFim'] is Timestamp) {
      dataFim = (data['dataFim'] as Timestamp).toDate();
    } else if (data['dataFim'] is DateTime) {
      dataFim = data['dataFim'] as DateTime;
    } else {
      return 999;
    }

    DateTime baseDate = DateTime(date.year, date.month, date.day);
    dataFim = DateTime(dataFim.year, dataFim.month, dataFim.day);

    return dataFim.difference(baseDate).inDays;
  }

  bool _isMedicamentoAtiveOnDate(Map<String, dynamic> data, DateTime date) {
    if (data['dataInicio'] == null) return false;

    DateTime dataInicio;
    if (data['dataInicio'] is Timestamp) {
      dataInicio = (data['dataInicio'] as Timestamp).toDate();
    } else if (data['dataInicio'] is DateTime) {
      dataInicio = data['dataInicio'] as DateTime;
    } else {
      return false;
    }

    dataInicio = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);
    DateTime selectedDate = DateTime(date.year, date.month, date.day);

    if (dataInicio.isAfter(selectedDate)) return false;

    if (data['dataFim'] != null) {
      DateTime dataFim;
      if (data['dataFim'] is Timestamp) {
        dataFim = (data['dataFim'] as Timestamp).toDate();
      } else if (data['dataFim'] is DateTime) {
        dataFim = data['dataFim'] as DateTime;
      } else {
        return true;
      }
      dataFim = DateTime(dataFim.year, dataFim.month, dataFim.day);
      if (selectedDate.isAfter(dataFim)) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background2.png',
              fit: BoxFit.cover,
            ),
          ),
          // Cabeçalho similar ao paciente_page
          if (!isLoading)
            Positioned(
              top: 64,
              left: 24,
              right: 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        (idosoData?['fotoUrl'] != null &&
                            idosoData!['fotoUrl'].toString().isNotEmpty)
                        ? (idosoData!['isAsset'] == true
                              ? AssetImage(idosoData!['fotoUrl'])
                              : NetworkImage(idosoData!['fotoUrl'])
                                    as ImageProvider)
                        : null,
                    child:
                        (idosoData?['fotoUrl'] == null ||
                            idosoData!['fotoUrl'].toString().isEmpty)
                        ? const Icon(Icons.person, color: Colors.grey, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.90),
                        borderRadius: BorderRadius.circular(38),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.0,
                            color: Color(0xFF3A7CA5),
                          ),
                          children: [
                            const TextSpan(text: 'MEDICAMENTOS: '),
                            TextSpan(
                              text: widget.apelido.toUpperCase(),
                              style: const TextStyle(color: Color(0xFF3A7CA5)),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 140),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getMedicamentosByIdoso(widget.idosoId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Align(
                      alignment: const Alignment(0, -0.12),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.82,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.medical_services,
                              size: 48,
                              color: const Color(0xFF3A7CA5),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Nenhum medicamento cadastrado.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3A7CA5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6DBE81),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 4,
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text(
                                'Adicionar medicamento',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterMedicamentosPage(
                                          idosoId: widget.idosoId,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Ordenar medicamentos por duração restante
                final sortedDocs = List.from(docs);
                sortedDocs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final daysA = _getDaysRemaining(dataA);
                  final daysB = _getDaysRemaining(dataB);
                  return daysA.compareTo(daysB);
                });

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Calendário com suporte a retrair/expandir e localizado em pt_BR
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Calendário',
                                  style: TextStyle(
                                    color: Color(0xFF3A7CA5),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _calendarExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: const Color(0xFF3A7CA5),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _calendarExpanded = !_calendarExpanded;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedCrossFade(
                            firstChild: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TableCalendar(
                                locale: 'pt_BR',
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                selectedDayPredicate: (day) =>
                                    isSameDay(_selectedDay, day),
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                },
                                calendarStyle: CalendarStyle(
                                  todayDecoration: BoxDecoration(
                                    color: const Color(0xFF3A7CA5),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: BoxDecoration(
                                    color: const Color(0xFF6DBE81),
                                    shape: BoxShape.circle,
                                  ),
                                  weekendTextStyle: const TextStyle(
                                    color: Color(0xFF3A7CA5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  defaultTextStyle: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                                headerStyle: const HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: TextStyle(
                                    color: Color(0xFF3A7CA5),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  leftChevronIcon: Icon(
                                    Icons.chevron_left,
                                    color: Color(0xFF3A7CA5),
                                  ),
                                  rightChevronIcon: Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF3A7CA5),
                                  ),
                                ),
                              ),
                            ),
                            secondChild: const SizedBox.shrink(),
                            crossFadeState: _calendarExpanded
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 200),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Filtro mais explícito: Mostrar: [Todos] [Data]
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Mostrar: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF3A7CA5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Caixa "Todos"
                            GestureDetector(
                              onTap: () {
                                if (filterByDate) {
                                  setState(() {
                                    filterByDate = false; // Todos
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: !filterByDate,
                                    onChanged: (v) {
                                      if (v == true) {
                                        setState(() {
                                          filterByDate = false;
                                        });
                                      }
                                    },
                                    activeColor: const Color(0xFF6DBE81),
                                  ),
                                  const Text('Todos'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Caixa "Data"
                            GestureDetector(
                              onTap: () {
                                if (!filterByDate) {
                                  setState(() {
                                    filterByDate = true; // Data
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: filterByDate,
                                    onChanged: (v) {
                                      if (v == true) {
                                        setState(() {
                                          filterByDate = true;
                                        });
                                      }
                                    },
                                    activeColor: const Color(0xFF6DBE81),
                                  ),
                                  Text(
                                    'Data (${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year})',
                                    style: const TextStyle(
                                      color: Color(0xFF3A7CA5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Lista de medicamentos
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            // Filtrar medicamentos conforme o toggle
                            final filteredDocs = sortedDocs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              if (filterByDate) {
                                // Filtro por data: mostra só os ativos na data selecionada
                                return _isMedicamentoAtiveOnDate(
                                  data,
                                  _selectedDay,
                                );
                              } else {
                                // Todos os medicamentos: mostra todos registrados
                                return true;
                              }
                            }).toList();

                            if (filteredDocs.isEmpty) {
                              return Center(
                                child: Text(
                                  filterByDate
                                      ? 'Nenhum medicamento nesta data'
                                      : 'Nenhum medicamento cadastrado',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.only(top: 4),
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) {
                                final doc = filteredDocs[index];
                                final data = doc.data() as Map<String, dynamic>;
                                // Sempre avalia o status com base na data selecionada no calendário.
                                // Quando filterByDate == true, a lista já foi filtrada para mostrar
                                // apenas os ativos nessa data; quando false, mostramos todos os
                                // medicamentos, mas o rótulo de ativo/inativo é calculado
                                // com base na data selecionada (_selectedDay).
                                final isActive = _isMedicamentoAtiveOnDate(
                                  data,
                                  _selectedDay,
                                );
                                final daysRemaining = _getDaysRemainingOnDate(
                                  data,
                                  _selectedDay,
                                );

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border(
                                      left: BorderSide(
                                        color: isActive
                                            ? const Color(0xFF6DBE81)
                                            : Colors.grey,
                                        width: 5,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data['nome'] ?? 'Sem nome',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF3A7CA5),
                                            ),
                                          ),
                                        ),
                                        if (isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF6DBE81,
                                              ).withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Ativo',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6DBE81),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        if (!isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Inativo',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        if ((data.containsKey('dosagem') &&
                                                data.containsKey(
                                                  'unidadeDosagem',
                                                )) ==
                                            true)
                                          Text(
                                            'Dosagem: ${data['dosagem']} ${data['unidadeDosagem']}',
                                            style: const TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                        if (data.containsKey('horarioInicio'))
                                          Text(
                                            'Horário: ${data['horarioInicio']}',
                                            style: const TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                        if ((data.containsKey('periodo') &&
                                                data.containsKey(
                                                  'unidadePeriodo',
                                                )) ==
                                            true)
                                          Text(
                                            'Período: ${data['periodo']} ${data['unidadePeriodo']}',
                                            style: const TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                        if (data.containsKey('dataInicio'))
                                          Text(
                                            'Início: ${_formatDate(data['dataInicio'])}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        if (daysRemaining != 999 && isActive)
                                          Text(
                                            'Termina em: $daysRemaining dias',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: daysRemaining <= 7
                                                  ? Colors.red
                                                  : Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        if (daysRemaining == 999)
                                          const Text(
                                            'Fim: Indefinido',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      color: Colors.white,
                                      onSelected: (value) async {
                                        if (value == 'editar') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RegisterMedicamentosPage(
                                                    idosoId: widget.idosoId,
                                                    medicamentoId: doc.id,
                                                    medicamentoData: data,
                                                  ),
                                            ),
                                          );
                                        } else if (value == 'excluir') {
                                          await _firestoreService
                                              .removeMedicamentoApp(doc.id);
                                          setState(() {});
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'editar',
                                          child: Text('Editar'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'excluir',
                                          child: Text('Excluir'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Removido overlay de carregamento para evitar dois ícones simultâneos
          // Menu circular
          Padding(
            padding: const EdgeInsets.only(bottom: 56),
            child: CircularMenu(
              alignment: Alignment.bottomCenter,
              toggleButtonColor: const Color.fromARGB(255, 108, 81, 182),
              toggleButtonIconColor: Colors.white,
              items: [
                CircularMenuItem(
                  icon: Icons.arrow_back,
                  color: Colors.grey,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                CircularMenuItem(
                  icon: Icons.add,
                  color: const Color(0xFF6DBE81),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RegisterMedicamentosPage(idosoId: widget.idosoId),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
