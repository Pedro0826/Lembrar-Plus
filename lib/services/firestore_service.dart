
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> isResponsavelByEmail(String email) async {
    final snap = await _db.collection('responsavel').where('email', isEqualTo: email).limit(1).get();
    return snap.docs.isNotEmpty;
  }

  Future<bool> isIdosoByEmail(String email) async {
    final snap = await _db.collection('idoso').where('email', isEqualTo: email).limit(1).get();
    return snap.docs.isNotEmpty;
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
    final docRef = await _db.collection('idoso').add({
      'nome': nome,
      'email': email,
    });
    return docRef.id;
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
    });
    return docRef.id;
  }

  Future<void> addMedicamento({
    required int codigoMedicamento,
    required String nome,
    required String dosagem,
    required String observacoes,
    required int codigoIdoso,
  }) async {
    await _db.collection('medicamento').doc(codigoMedicamento.toString()).set({
      'codigo_medicamento': codigoMedicamento,
      'nome': nome,
      'dosagem': dosagem,
      'observacoes': observacoes,
      'codigo_idoso': codigoIdoso,
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
}
