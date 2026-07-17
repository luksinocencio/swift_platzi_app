import Foundation

/// Camada de dados da API Platzi. Não guarda estado — quem guarda é o ViewModel.
///
/// Toda função segue a mesma receita:
/// 1. Monta um `Resource` dizendo a URL, o verbo e o tipo esperado na resposta.
/// 2. Entrega ao `HTTPClient`, que executa e decodifica.
/// 3. Retorna o modelo pronto para o ViewModel.
///
/// As chamadas ficam organizadas em extensões, uma por domínio:
/// - `PlatziService+Categories.swift`
/// - `PlatziService+Products.swift`
/// - `PlatziService+Locations.swift`
struct PlatziService {
    let httpClient: HTTPClient

    init(httpClient: HTTPClient = HTTPClient()) {
        self.httpClient = httpClient
    }
}
