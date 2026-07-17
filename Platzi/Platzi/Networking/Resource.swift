import Foundation

/// Descreve TUDO que uma chamada de rede precisa:
/// para onde vai (`url`), como vai (`method`), o que envia (`body`/`queryItems`)
/// e o que espera receber de volta (`modelType`).
///
/// O genérico `T` é o tipo Swift em que o JSON da resposta será decodificado.
///
/// Exemplos:
/// ```swift
/// // GET simples — só precisa da URL e do tipo esperado
/// Resource(url: Constants.Urls.categories, modelType: [Category].self)
///
/// // POST com corpo JSON
/// Resource(url: Constants.Urls.login, method: .post, body: try request.encode(), modelType: LoginResponse.self)
/// ```
struct Resource<T: Codable> {
    /// Endereço do endpoint.
    let url: URL

    /// Verbo HTTP. GET é o padrão.
    var method: HTTPMethod = .get

    /// Corpo da requisição em JSON (usado em POST/PUT).
    var body: Data? = nil

    /// Parâmetros de query string (ex.: ?page=1&limit=10).
    var queryItems: [URLQueryItem] = []

    /// Headers extras, além dos padrões da sessão.
    var headers: [String: String]? = nil

    /// O tipo em que a resposta será decodificada (ex.: `[Category].self`).
    var modelType: T.Type
}
