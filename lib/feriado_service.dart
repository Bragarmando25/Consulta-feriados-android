import 'dart:convert';
import 'package:http/http.dart' as http;
import 'feriado.dart';


// Classe responsável por acessar a BrasilAPI.

class FeriadoService {

  // Busca todos os feriados de um determinado ano.

  Future<List<Feriado>> buscarAno(int ano) async {

    // Faz uma requisição GET para a BrasilAPI.
    final resposta = await http.get(
      Uri.parse(
        'https://brasilapi.com.br/api/feriados/v1/$ano',
      ),
    );

    // O código HTTP 200 significa que a requisição foi realizada com sucesso.
    if (resposta.statusCode != 200) {
      throw Exception(
        'Erro ao consultar a API',
      );
    }

    // Converte a resposta recebida da API, que está em JSON, para uma lista do Dart.
    final List dados = jsonDecode(
      utf8.decode(
        resposta.bodyBytes,
      ),
    );


    // Percorre todos os dados recebidos. Cada item do JSON é transformado em um objeto Feriado.
    return dados
        .map(
          (item) => Feriado.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}