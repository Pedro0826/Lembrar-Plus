import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getMedicamentosByIdoso(String idosoId) {
    return _db
        .collection('medicamentos')
        .where('idosoId', isEqualTo: idosoId)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> removeMedicamentoApp(String medicamentoId) async {
    await _db.collection('medicamentos').doc(medicamentoId).delete();
  }

  Future<bool> isResponsavelByEmail(String email) async {
    final snap = await _db
        .collection('responsavel')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<bool> isIdosoByEmail(String email) async {
    final snap = await _db
        .collection('idoso')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  // Busca documento do responsável pelo e-mail
  Future<Map<String, dynamic>?> getResponsavelByEmail(String email) async {
    final snap = await _db
        .collection('responsavel')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return {...doc.data(), 'id': doc.id};
  }

  Future<Map<String, dynamic>?> getIdosoByCodigo(String codigo) async {
    final query = await _db
        .collection('idoso')
        .where('codigo', isEqualTo: codigo)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    final data = doc.data();
    data['id'] = doc.id; // <-- ESSENCIAL!
    return data;
  }

  // Busca lista de idosos por IDs
  Future<List<Map<String, dynamic>>> getIdososByIds(List<dynamic> ids) async {
    if (ids.isEmpty) return [];
    final snap = await _db
        .collection('idoso')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  // Vincula idoso ao responsável (adiciona vínculo em ambos os lados)
  Future<void> vincularIdosoAoResponsavel(
    String responsavelEmail,
    String idosoId,
  ) async {
    final snap = await _db
        .collection('responsavel')
        .where('email', isEqualTo: responsavelEmail)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return;
    final doc = snap.docs.first;
    final responsavelId = doc.id;

    // Adiciona idoso à lista do responsável
    List<dynamic> idososVinculados = doc.data()['idosos_vinculados'] ?? [];
    if (!idososVinculados.contains(idosoId)) {
      idososVinculados.add(idosoId);

      // Busca o documento do idoso
      final idosoDoc = await _db.collection('idoso').doc(idosoId).get();
      List<dynamic> responsaveisVinculados =
          idosoDoc.data()?['responsaveis'] ?? [];

      // Adiciona responsável à lista do idoso (se não estiver já)
      if (!responsaveisVinculados.contains(responsavelId)) {
        responsaveisVinculados.add(responsavelId);
      }

      // Atualiza ambos os documentos
      await Future.wait([
        _db.collection('responsavel').doc(responsavelId).update({
          'idosos_vinculados': idososVinculados,
        }),
        _db.collection('idoso').doc(idosoId).update({
          'responsaveis': responsaveisVinculados,
        }),
      ]);
    }
  }

  /// Atualiza os dados do idoso após o vínculo com o responsável
  Future<void> atualizarDadosIdoso({
    required String idosoId,
    required String cpf,
    required DateTime dataNasc,
    required String telefone,
    required String convenio,
    required String tipoSanguineo,
    required double peso,
    required double altura,
  }) async {
    await _db.collection('idoso').doc(idosoId).update({
      'cpf': cpf,
      'data_nasc': dataNasc,
      'telefone': telefone,
      'convenio': convenio,
      'tipo_sanguineo': tipoSanguineo,
      'peso': peso,
      'altura': altura,
    });
  }

  Future<void> adicionarCodigoIdosoAoResponsavel({
    required String responsavelId,
    required String codigoIdoso,
  }) async {
    await _db.collection('responsavel').doc(responsavelId).update({
      'codigo_idoso': codigoIdoso,
    });
  }

  Future<void> addIdoso({
    required String uid,
    required String nome,
    required String email,
  }) async {
    String codigo;
    do {
      codigo = _gerarCodigoCurto(6);
    } while (await _codigoExiste(codigo));
    await _db.collection('idoso').doc(uid).set({
      'nome': nome,
      'email': email,
      'codigo': codigo,
      'responsaveis': [],
    });
  }

  String _gerarCodigoCurto(int tamanho) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(
      tamanho,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  Future<bool> _codigoExiste(String codigo) async {
    final snap = await _db
        .collection('idoso')
        .where('codigo', isEqualTo: codigo)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> addResponsavel({
    required String uid,
    required String nome,
    required String telefone,
    required String email,
    required DateTime dataNasc,
    required String cpf,
  }) async {
    await _db.collection('responsavel').doc(uid).set({
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'data_nasc': dataNasc,
      'cpf': cpf,
      'idosos_vinculados': [], // inicializa como lista vazia
    });
  }

  Future<void> addMedicamento({
    required String idosoId,
    required String nome,
    required String dosagem,
    required String unidadeDosagem,
    required Timestamp dataInicio, // Agora é Timestamp
    Timestamp? dataFim, // Opcional
    String? horarioInicio, // String no formato "HH:mm"
    required int periodo,
    required String unidadePeriodo,
    required String observacoes,
  }) async {
    await FirebaseFirestore.instance.collection('medicamentos').add({
      'idosoId': idosoId,
      'nome': nome,
      'dosagem': dosagem,
      'unidadeDosagem': unidadeDosagem,
      'dataInicio': dataInicio, // Salva como Timestamp
      'dataFim': dataFim, // Salva como Timestamp ou null
      'horarioInicio': horarioInicio, // Salva como String
      'periodo': periodo,
      'unidadePeriodo': unidadePeriodo,
      'observacoes': observacoes,
      'createdAt': FieldValue.serverTimestamp(), // Timestamp gerado no servidor
    });
  }

  Future<void> criarNotificacao({
    required String codigoIdoso,
    required String conteudo,
    required DateTime hora,
    required String importancia,
    required bool status,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notificacao').add({
        'codigoIdoso': codigoIdoso,
        'conteudo': conteudo,
        'hora': Timestamp.fromDate(hora),
        'importancia': importancia,
        'status': status,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addCalendarioMedicamento({
    required int codigoCalendario,
    required int codigoMedicamento,
    required DateTime dataHora,
    required String status,
  }) async {
    await _db
        .collection('calendario_medicamento')
        .doc(codigoCalendario.toString())
        .set({
          'codigo_calendario': codigoCalendario,
          'codigo_medicamento': codigoMedicamento,
          'data_hora': dataHora,
          'status': status,
        });
  }

  // Remove vínculo entre responsável e idoso (remove de ambos os lados)
  Future<void> removerVinculoResponsavelIdoso(
    String responsavelId,
    String idosoId,
  ) async {
    // Busca o documento do responsável
    final responsavelDoc = await _db
        .collection('responsavel')
        .doc(responsavelId)
        .get();
    List<dynamic> idososVinculados =
        responsavelDoc.data()?['idosos_vinculados'] ?? [];

    // Remove o idoso da lista do responsável
    idososVinculados.remove(idosoId);

    // Busca o documento do idoso
    final idosoDoc = await _db.collection('idoso').doc(idosoId).get();
    List<dynamic> responsaveisVinculados =
        idosoDoc.data()?['responsaveis'] ?? [];

    // Remove o responsável da lista do idoso
    responsaveisVinculados.remove(responsavelId);

    // Atualiza ambos os documentos simultaneamente
    await Future.wait([
      _db.collection('responsavel').doc(responsavelId).update({
        'idosos_vinculados': idososVinculados,
      }),
      _db.collection('idoso').doc(idosoId).update({
        'responsaveis': responsaveisVinculados,
      }),
    ]);
  }

  Future<void> adicionarResponsavelNoIdoso(idosoSnap, String s) async {}
}
