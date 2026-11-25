import 'package:flutter/material.dart';
import 'models.dart';

// Etiqueta colorida (Disponível, Atenção, Restrição...)
class StatusTag extends StatelessWidget {
  final String texto;
  final Color cor;
  const StatusTag(this.texto, this.cor, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(texto,
          style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

// ---------------------------------------------------------------- 2. DASHBOARD
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Widget _card(String numero, String texto, Color cor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(numero,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: cor)),
            Text(texto),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int quantos(Gravidade g) => veiculos.where((v) => v.status == g).length;

    final ultimos = <(Veiculo, Checklist)>[];
    for (final v in veiculos) {
      for (final c in v.historico) {
        ultimos.add((v, c));
      }
    }
    ultimos.sort((a, b) => b.$2.data.compareTo(a.$2.data));

    return Scaffold(
      appBar: AppBar(title: const Text('Frota360')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Olá, $usuarioLogado!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('Bom dia! Aqui está o resumo da frota.'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2,
            children: [
              _card('${veiculos.length}', 'Veículos', Colors.blue),
              _card('${quantos(Gravidade.normal)}', 'Disponíveis', Colors.green),
              _card('${quantos(Gravidade.atencao)}', 'Em atenção', Colors.orange),
              _card('${quantos(Gravidade.critico)}', 'Com restrição', Colors.red),
            ],
          ),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Novo Checklist'),
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ListaVeiculosPage()));
                setState(() {}); // atualiza ao voltar
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text('Últimos checklists',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (ultimos.isEmpty) const Text('Nenhum checklist feito ainda.'),
          ...ultimos.take(3).map((u) => ListTile(
                title: Text(u.$1.codigo),
                subtitle: Text(formatar(u.$2.data)),
                trailing: StatusTag(nomeDe(u.$2.situacao), corDe(u.$2.situacao)),
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- 3. LISTA DE VEÍCULOS
class ListaVeiculosPage extends StatefulWidget {
  const ListaVeiculosPage({super.key});

  @override
  State<ListaVeiculosPage> createState() => _ListaVeiculosPageState();
}

class _ListaVeiculosPageState extends State<ListaVeiculosPage> {
  String busca = '';

  @override
  Widget build(BuildContext context) {
    final lista = veiculos.where((v) {
      final texto = '${v.codigo} ${v.modelo} ${v.placa}'.toLowerCase();
      return texto.contains(busca.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Veículos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Pesquisar por placa, nome...',
                border: OutlineInputBorder(),
              ),
              onChanged: (valor) => setState(() => busca = valor),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, i) {
                final v = lista[i];
                return ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text(v.codigo),
                  subtitle: Text('${v.modelo}\n${v.placa}'),
                  isThreeLine: true,
                  trailing: StatusTag(v.textoStatus, corDe(v.status)),
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => DetalhesPage(v)));
                    setState(() {});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------- 4. DETALHES DO VEÍCULO
class DetalhesPage extends StatefulWidget {
  final Veiculo veiculo;
  const DetalhesPage(this.veiculo, {super.key});

  @override
  State<DetalhesPage> createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  @override
  Widget build(BuildContext context) {
    final v = widget.veiculo;
    final cor = corDe(v.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Veículo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(v.codigo,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              StatusTag(v.textoStatus, cor),
            ],
          ),
          const SizedBox(height: 8),
          Text('Modelo: ${v.modelo}'),
          Text('Placa: ${v.placa}'),
          Text('Ano: ${v.ano}'),
          Text('Km: ${v.km} km'),
          const SizedBox(height: 16),
          const Text('Saúde do veículo',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                        value: v.saude / 100, color: cor, strokeWidth: 8),
                    Text('${v.saude}%',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ChecklistPage(v)));
                setState(() {}); // atualiza saúde e histórico
              },
              child: const Text('Iniciar Checklist'),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Histórico de checklists',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (v.historico.isEmpty) const Text('Nenhum checklist ainda.'),
          ...v.historico.map((c) => ListTile(
                title: Text(formatar(c.data)),
                subtitle: Text('Realizado por ${c.autor}'),
                trailing: StatusTag(nomeDe(c.situacao), corDe(c.situacao)),
              )),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- 5. CHECKLIST
class ChecklistPage extends StatefulWidget {
  final Veiculo veiculo;
  const ChecklistPage(this.veiculo, {super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  // todos os itens começam como Normal
  final Map<String, Gravidade> respostas = {
    for (final i in itensChecklist) i: Gravidade.normal,
  };
  final Map<String, String> avarias = {};

  Future<void> _escolher(String item, Gravidade g) async {
    if (g == Gravidade.normal) {
      setState(() {
        respostas[item] = g;
        avarias.remove(item);
      });
      return;
    }
    // Atenção ou Crítico: abre a tela de registrar avaria
    final r = await Navigator.push<(Gravidade, String)>(
      context,
      MaterialPageRoute(builder: (_) => AvariaPage(item, g)),
    );
    if (r != null) {
      setState(() {
        respostas[item] = r.$1;
        avarias[item] = r.$2;
      });
    }
  }

  Future<void> _proximo() async {
    final checklist = Checklist(
      data: DateTime.now(),
      autor: usuarioLogado,
      respostas: Map.of(respostas),
      avarias: Map.of(avarias),
    );
    final finalizou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ResumoPage(widget.veiculo, checklist)),
    );
    if (finalizou == true) {
      widget.veiculo.historico.insert(0, checklist);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checklist - ${widget.veiculo.codigo}')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: itensChecklist.map((item) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 8,
                          children: Gravidade.values.map((g) {
                            return ChoiceChip(
                              label: Text(nomeDe(g)),
                              selected: respostas[item] == g,
                              selectedColor: corDe(g).withAlpha(70),
                              onSelected: (_) => _escolher(item, g),
                            );
                          }).toList(),
                        ),
                        if (avarias[item] != null && avarias[item]!.isNotEmpty)
                          Text(avarias[item]!,
                              style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _proximo,
                child: const Text('Próximo'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- 6. REGISTRAR AVARIA
class AvariaPage extends StatefulWidget {
  final String item;
  final Gravidade gravidadeInicial;
  const AvariaPage(this.item, this.gravidadeInicial, {super.key});

  @override
  State<AvariaPage> createState() => _AvariaPageState();
}

class _AvariaPageState extends State<AvariaPage> {
  final TextEditingController _descricao = TextEditingController();
  late Gravidade gravidade = widget.gravidadeInicial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Avaria')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: const Text('Item com problema'),
                subtitle: Text(widget.item),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Gravidade',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: [Gravidade.atencao, Gravidade.critico].map((g) {
                return ChoiceChip(
                  label: Text(nomeDe(g)),
                  selected: gravidade == g,
                  selectedColor: corDe(g).withAlpha(70),
                  onSelected: (_) => setState(() => gravidade = g),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Text('Descrição da avaria',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _descricao,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ex.: Pneu dianteiro com desgaste excessivo.',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, (gravidade, _descricao.text.trim())),
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ 7. RESUMO
class ResumoPage extends StatelessWidget {
  final Veiculo veiculo;
  final Checklist checklist;
  const ResumoPage(this.veiculo, this.checklist, {super.key});

  Widget _contador(String titulo, int n, Color cor) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(titulo, style: TextStyle(color: cor, fontSize: 12)),
              Text('$n',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final situacao = checklist.situacao;
    final cor = corDe(situacao);
    final mensagem = switch (situacao) {
      Gravidade.critico => 'Não recomendado para utilização.\nRealize a manutenção antes da liberação.',
      Gravidade.atencao => 'Utilização com acompanhamento.\nFique atento aos itens marcados.',
      Gravidade.normal => 'Veículo liberado para utilização.',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Resumo do Checklist')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(veiculo.codigo,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _contador('Total de itens', checklist.respostas.length, Colors.blue),
                _contador('Normais', checklist.conta(Gravidade.normal), Colors.green),
                _contador('Atenção', checklist.conta(Gravidade.atencao), Colors.orange),
                _contador('Críticos', checklist.conta(Gravidade.critico), Colors.red),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              color: cor.withAlpha(30),
              child: ListTile(
                title: const Text('Situação do veículo',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(mensagem),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Voltar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Finalizar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
