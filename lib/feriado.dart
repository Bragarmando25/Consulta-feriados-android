class Feriado {
  final String nome;
  final DateTime data;

  // Construtor da classe.
  Feriado({
    required this.nome,
    required this.data,
  });

// Converte os dados JSON recebidos da API em um objeto do tipo Feriado.
  factory Feriado.fromJson(
    Map<String, dynamic> json,
  ) {
    return Feriado(
      // Pega o nome do feriado.
      nome: json['name'],

      // Converte a data recebida como texto para um objeto DateTime.
      data: DateTime.parse(
        json['date'],
      ),
    );
  }
}