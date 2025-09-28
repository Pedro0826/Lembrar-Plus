import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class FirestoreService {
 
  Stream<QuerySnapshot> getMedicamentosByIdoso(String idosoId) {
    return _db.collection('medicamentos')
      .where('idosoId', isEqualTo: idosoId)
      .orderBy('createdAt', descending: false)
      .snapshots();
  }

  Future<void> removeMedicamentoApp(String medicamentoId) async {
    await _db.collection('medicamentos').doc(medicamentoId).delete();
  }
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> isResponsavelByEmail(String email) async {
    final snap = await _db.collection('responsavel').where('email', isEqualTo: email).limit(1).get();
    return snap.docs.isNotEmpty;
  }

  Future<bool> isIdosoByEmail(String email) async {
    final snap = await _db.collection('idoso').where('email', isEqualTo: email).limit(1).get();
    return snap.docs.isNotEmpty;
  }

  // Busca documento do responsável pelo e-mail
  Future<Map<String, dynamic>?> getResponsavelByEmail(String email) async {
    final snap = await _db.collection('responsavel').where('email', isEqualTo: email).limit(1).get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return {...doc.data(), 'id': doc.id};
  }

  // Busca documento do idoso pelo código
  Future<Map<String, dynamic>?> getIdosoByCodigo(String codigo) async {
    final snap = await _db.collection('idoso').where('codigo', isEqualTo: codigo).limit(1).get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return {...doc.data(), 'id': doc.id};
  }


  // Busca lista de idosos por IDs
  Future<List<Map<String, dynamic>>> getIdososByIds(List<dynamic> ids) async {
    if (ids.isEmpty) return [];
    final snap = await _db.collection('idoso').where(FieldPath.documentId, whereIn: ids).get();
    return snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  // Vincula idoso ao responsável (adiciona id do idoso à lista)
  Future<void> vincularIdosoAoResponsavel(String responsavelEmail, String idosoId) async {
    final snap = await _db.collection('responsavel').where('email', isEqualTo: responsavelEmail).limit(1).get();
    if (snap.docs.isEmpty) return;
    final doc = snap.docs.first;
    List<dynamic> ids = doc.data()['idosos_vinculados'] ?? [];
    if (!ids.contains(idosoId)) {
      ids.add(idosoId);
      await _db.collection('responsavel').doc(doc.id).update({'idosos_vinculados': ids});
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

  Future<String> addIdoso({
    required String nome,
    required String email,
  }) async {
    String codigo;
    do {
      codigo = _gerarCodigoCurto(6);
    } while (await _codigoExiste(codigo));
    final docRef = await _db.collection('idoso').add({
      'nome': nome,
      'email': email,
      'codigo': codigo,
    });
    return docRef.id;
  }

  String _gerarCodigoCurto(int tamanho) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(tamanho, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<bool> _codigoExiste(String codigo) async {
    final snap = await _db.collection('idoso').where('codigo', isEqualTo: codigo).limit(1).get();
    return snap.docs.isNotEmpty;
  }

  Future<String> addResponsavel({
    required String nome,
    required String telefone,
    required String email,
    required DateTime dataNasc,
    required String cpf,
  }) async {
    final docRef = await _db.collection('responsavel').add({
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'data_nasc': dataNasc,
      'cpf': cpf,
      'idosos_vinculados': [], // inicializa como lista vazia
    });
    return docRef.id;
  }

  Future<void> addMedicamento({
    required String idosoId,
    required String nome,
    required String dosagem,
    required int prazoDias,
    required String observacoes,
  }) async {
    await _db.collection('medicamentos').add({
      'idosoId': idosoId,
      'nome': nome,
      'dosagem': dosagem,
      'prazoDias': prazoDias,
      'observacoes': observacoes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addCalendarioMedicamento({
    required int codigoCalendario,
    required int codigoMedicamento,
    required DateTime dataHora,
    required String status,
  }) async {
    await _db.collection('calendario_medicamento').doc(codigoCalendario.toString()).set({
      'codigo_calendario': codigoCalendario,
      'codigo_medicamento': codigoMedicamento,
      'data_hora': dataHora,
      'status': status,
    });
  }

  Future<void> adicionarResponsavelNoIdoso(idosoSnap, String s) async {}
}
