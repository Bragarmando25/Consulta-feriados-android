import 'package:flutter/material.dart';

import 'feriado.dart';
import 'feriado_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // Cria e retorna o estado da tela HomePage.
  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  List<Feriado> _feriados = [];
  bool _carregando = false;
  String? _erro;

  final FeriadoService _service = FeriadoService();

  // Executado uma vez quando a tela é criada.
  // Faz a busca dos feriados automaticamente.
  @override
  void initState() {
    super.initState();
    _buscarFeriados();
  }

  // Retorna a data atual considerando o horário de Brasília.
  DateTime get hojeBrasilia {
    final agora = DateTime.now()
        .toUtc()
        .subtract(const Duration(hours: 3));

    return DateTime(
      agora.year,
      agora.month,
      agora.day,
    );
  }

  // Busca os feriados do ano atual e do próximo ano.
  // Depois junta as listas, remove os feriados que já passaram
  // e ordena os restantes pela data.
  Future<void> _buscarFeriados() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final hoje = hojeBrasilia;

      final respostas = await Future.wait([
        _service.buscarAno(hoje.year),
        _service.buscarAno(hoje.year + 1),
      ]);

      final feriados = respostas
          .expand((lista) => lista)
          .where(
            (feriado) => !feriado.data.isBefore(hoje),
          )
          .toList();

      feriados.sort(
        (a, b) => a.data.compareTo(b.data),
      );

      if (!mounted) return;

      setState(() {
        _feriados = feriados;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _erro = 'Não foi possível buscar os feriados.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  // Abre um popup com o nome, a data e
  // quantos dias faltam para o feriado selecionado.
  void _mostrarFeriado(Feriado feriado) {
    final dias =
        feriado.data.difference(hojeBrasilia).inDays;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(feriado.nome),
          content: Text(
            '${formatarData(feriado.data)}\n\n'
            '${textoDias(dias)}',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // Monta a interface principal da tela.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feriados Nacionais'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.calendar_month,
              size: 54,
            ),

            const SizedBox(height: 10),

            const Text(
              'Consulta de Feriados',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Hoje: ${formatarData(hojeBrasilia)} '
              '(horário de Brasília)',
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _montarConteudo(),
            ),
          ],
        ),
      ),
    );
  }

  // Decide o que será mostrado na tela.
  // Pode mostrar o carregamento, um erro,
  // uma mensagem de lista vazia ou os feriados.
  Widget _montarConteudo() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red,
            ),

            const SizedBox(height: 10),

            Text(
              _erro!,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 10),

            FilledButton(
              onPressed: _buscarFeriados,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_feriados.isEmpty) {
      return const Center(
        child: Text('Nenhum feriado encontrado.'),
      );
    }

    final proximo = _feriados.first;

    final diasProximo =
        proximo.data.difference(hojeBrasilia).inDays;

    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.upcoming),
            title: Text(
              'Próximo feriado: ${proximo.nome}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${formatarData(proximo.data)} • '
              '${textoDias(diasProximo)}',
            ),
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Toque em um feriado para ver quantos dias faltam.',
        ),

        const SizedBox(height: 10),

        Expanded(
          child: ListView.builder(
            itemCount: _feriados.length,
            itemBuilder: (context, index) {
              final feriado = _feriados[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(feriado.nome),
                  subtitle: Text(
                    formatarData(feriado.data),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    _mostrarFeriado(feriado);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Converte uma data para o formato DD/MM/AAAA.
String formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');

  return '$dia/$mes/${data.year}';
}

// Cria o texto referente à quantidade de dias restantes.
String textoDias(int dias) {
  if (dias == 0) {
    return 'É hoje!';
  }

  if (dias == 1) {
    return 'Falta 1 dia.';
  }

  return 'Faltam $dias dias.';
}