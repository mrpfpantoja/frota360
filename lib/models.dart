import 'package:flutter/material.dart';

enum Gravidade { normal, atencao, critico }

Color corDe(Gravidade g) => switch (g) {
      Gravidade.normal => Colors.green,
      Gravidade.atencao => Colors.orange,
      Gravidade.critico => Colors.red,
    };

String nomeDe(Gravidade g) => switch (g) {
      Gravidade.normal => 'Normal',
      Gravidade.atencao => 'Atenção',
      Gravidade.critico => 'Crítico',
    };

String formatar(DateTime d) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(d.day)}/${dois(d.month)}/${d.year} ${dois(d.hour)}:${dois(d.minute)}';
}

// Um checklist já feito
class Checklist {
  final DateTime data;
  final String autor;
  final Map<String, Gravidade> respostas; // item -> gravidade
  final Map<String, String> avarias; // item -> descrição

  Checklist({
    required this.data,
    required this.autor,
    required this.respostas,
    required this.avarias,
  });

  int conta(Gravidade g) => respostas.values.where((v) => v == g).length;

  Gravidade get situacao {
    if (conta(Gravidade.critico) > 0) return Gravidade.critico;
    if (conta(Gravidade.atencao) > 0) return Gravidade.atencao;
    return Gravidade.normal;
  }

  // Normal vale 100, Atenção vale 50, Crítico vale 0
  int get saude => ((conta(Gravidade.normal) * 100 + conta(Gravidade.atencao) * 50) /
          respostas.length)
      .round();
}

class Veiculo {
  final String codigo, modelo, placa;
  final int ano, km;
  final List<Checklist> historico = []; // o mais novo fica na posição 0

  Veiculo(this.codigo, this.modelo, this.placa, this.ano, this.km);

  Gravidade get status =>
      historico.isEmpty ? Gravidade.normal : historico.first.situacao;

  int get saude => historico.isEmpty ? 100 : historico.first.saude;

  String get textoStatus => switch (status) {
        Gravidade.normal => 'Disponível',
        Gravidade.atencao => 'Atenção',
        Gravidade.critico => 'Restrição',
      };
}

const itensChecklist = [
  'Pneus',
  'Freios',
  'Luzes (faróis, setas, lanternas)',
  'Óleo do motor',
  'Bateria',
  'Nível de água do radiador',
];

String usuarioLogado = 'Usuário';

// Dados "de mentira" guardados só na memória
final List<Veiculo> veiculos = [
  Veiculo('VTR-001', 'Toyota Corolla', 'QSF-1234', 2022, 31200),
  Veiculo('VTR-002', 'Renault Duster', 'QSF-5678', 2021, 52430),
  Veiculo('VTR-003', 'Chevrolet Onix', 'QSF-9012', 2020, 68900),
  Veiculo('VTR-004', 'Volkswagen Polo', 'QSF-3456', 2023, 15800),
  Veiculo('VTR-005', 'Fiat Argo', 'QSF-7890', 2022, 40100),
];

void carregarExemplo() {
  if (veiculos[1].historico.isNotEmpty) return;
  veiculos[1].historico.add(Checklist(
    data: DateTime(2026, 9, 30, 10, 24),
    autor: 'Juliane',
    respostas: {
      for (final i in itensChecklist) i: Gravidade.normal,
      'Pneus': Gravidade.critico,
      'Freios': Gravidade.atencao,
    },
    avarias: {'Pneus': 'Pneu dianteiro com desgaste excessivo.'},
  ));
}
