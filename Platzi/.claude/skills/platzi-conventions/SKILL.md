---
name: platzi-conventions
description: Arquitetura, padrões e convenções do app Platzi (iOS/SwiftUI). Use ao criar telas, endpoints, models, DTOs ou qualquer código novo neste projeto, para manter consistência com os padrões existentes.
---

# Platzi App — Guia de Arquitetura e Convenções

App iOS em SwiftUI que consome a [Platzi Fake Store API](https://api.escuelajs.co/api/v1). Siga este guia para gerar código consistente com os padrões existentes.

## 1. Visão Geral

- **Plataforma:** iOS 26+, SwiftUI puro (sem UIKit, sem Storyboards); Liquid Glass disponível (`.buttonStyle(.glassProminent)`, `.glassEffect()`).
- **Arquitetura:** **MVVM** — um ViewModel `@Observable` por tela com estado; camada de serviço stateless (`PlatziService`).
- **Concorrência:** `async`/`await`. **Nunca usar Combine.**
- **Observação de estado:** framework `Observation` (`@Observable`, `@Environment`), **não** `ObservableObject`/`@Published`.
- **Idioma do código:** identificadores e strings de UI em inglês.
- **Backend:** `https://api.escuelajs.co/api/v1` (autenticação JWT com refresh token).

### Funcionalidades
Autenticação (login/registro/refresh/logout), categorias, produtos (listar/criar/deletar), localizações com mapa (MapKit) e perfil.

## 2. Estrutura de Pastas

```
Platzi/Platzi/
├── PlatziApp.swift          # Entry point (@main), roteamento auth, ErrorState global
├── Controllers/             # Serviço de autenticação (AuthenticationController)
├── Services/                # Camada de dados stateless (PlatziService)
├── ViewModels/              # Um ViewModel por tela com estado (sufixo *ViewModel)
├── Networking/              # HTTPClient, Resource, HTTPMethod
├── Models/                  # Modelos de domínio (Category, Product, Location)
├── DTOs/                    # Requests/responses da API (um arquivo por tipo)
├── Errors/                  # NetworkError, ErrorState + globalErrorAlert
├── Extensions/              # Extensões de tipos (String, URL, Environment, etc.)
├── Screens/                 # Telas (uma View por arquivo, sufixo *Screen)
├── Views/                   # Componentes reutilizáveis (sufixo *View / *CellView)
├── Utils/                   # Constants, JWTDecoder, KeychainWrapper
└── Assets.xcassets
```

**Regras de local:**
- Modelos de domínio (usados pelas views, `Identifiable`) → `Models/`, um arquivo por tipo.
- Requests/responses da API (`*Request`, `*Response`) → `DTOs/`, um arquivo por tipo.
- Telas → `Screens/` com sufixo `Screen`; componentes reutilizáveis → `Views/`.
- Estado e lógica de tela → `ViewModels/` com sufixo `ViewModel`.
- Chamadas de rede novas → método no `PlatziService` (domínio) ou `AuthenticationController` (auth); ViewModels chamam o serviço, nunca o `HTTPClient` direto.
- Telas puramente apresentacionais (ex.: `ProductDetailScreen`, `LocationDetailScreen`) não precisam de ViewModel.

## 3. Camada de Rede

### `Resource<T>` — descreve uma chamada
```swift
struct Resource<T: Codable> {
    let url: URL
    var method: HTTPMethod = .get([])
    var headers: [String: String]? = nil
    var modelType: T.Type
}
```

### `HTTPMethod`
`enum` com casos `.get([URLQueryItem])`, `.post(Data?)`, `.put(Data?)`, `.delete`, e propriedade `name` retornando o verbo HTTP.

### `HTTPClient`
- Método genérico `load<T: Codable>(_ resource:) async throws -> T`.
- Injeta automaticamente `Authorization: Bearer <accessToken>` a partir do Keychain.
- **Auto-refresh:** ao receber `401/unauthorized`, tenta `refreshToken()` e refaz a requisição uma vez; se falhar, lança `.unauthorized`.
- Mapeia status codes → `NetworkError` (200..<300 ok, 401 unauthorized, 404 notFound, resto `undefined`).
- Decodifica com `JSONDecoder()`; erro de decode vira `.decodingError`.

### Padrão para adicionar um endpoint
1. Adicione a URL em `Constants.Urls` (estática ou função se tiver parâmetro):
   ```swift
   static let categories = URL(string: "https://api.escuelajs.co/api/v1/categories")!
   static func deleteProduct(_ id: Int) -> URL { URL(string: "...\(id)")! }
   ```
2. Crie DTOs Codable de request/response em `DTOs/` (um arquivo por tipo).
3. Adicione um método **stateless** no `PlatziService` (dados de domínio) ou `AuthenticationController` (auth), retornando o valor:
   ```swift
   func loadCategories() async throws -> [Category] {
       let resource = Resource(url: Constants.Urls.categories, modelType: [Category].self)
       return try await httpClient.load(resource)
   }
   ```
4. Para POST/PUT, codifique o body com o helper `.encode()`:
   ```swift
   let resource = Resource(url: ..., method: .post(try request.encode()), modelType: Product.self)
   ```
5. Exponha o dado no ViewModel da tela, que guarda o estado.

## 4. MVVM — ViewModels & Injeção de Dependências

### ViewModel (um por tela com estado)
```swift
@MainActor
@Observable
class CategoryListViewModel {
    var categories: [Category] = []
    var isLoading: Bool = false

    private let service: PlatziService

    init(service: PlatziService = PlatziService()) {
        self.service = service
    }

    func loadCategories() async throws {
        isLoading = true
        defer { isLoading = false }
        categories = try await service.loadCategories()
    }
}
```
Regras:
- `@MainActor @Observable class`, sufixo `ViewModel`, em `ViewModels/`.
- Estado da tela (`isLoading`, listas, campos de formulário, `isFormValid`) vive no ViewModel.
- Dependências (`PlatziService`, `AuthenticationController`) injetadas no `init` com default — permite mock em testes.
- Métodos assíncronos **lançam** (`throws`); quem captura é a tela, roteando para o `ErrorState`.
- Criado na tela com `@State private var viewModel = XViewModel()`; se precisar de parâmetro, use `init` na tela com `_viewModel = State(initialValue: XViewModel(...))`.
- Bindings de formulário direto no VM: `TextField("Title", text: $viewModel.title)`.
- Dados criados em telas modais voltam por closure `onSave: (T) -> Void` e são inseridos no VM da tela pai (ex.: `viewModel.add(category)`).

### `PlatziService` — camada de dados
`struct` stateless em `Services/`; recebe `HTTPClient` no `init` (default). Só faz requisições e retorna valores — nunca guarda estado.

### `AuthenticationController`
- `struct` com `HTTPClient`; injetado via `EnvironmentValues` usando `@Entry`:
  ```swift
  extension EnvironmentValues {
      @Entry var authenticationController = AuthenticationController(httpClient: HTTPClient())
  }
  ```
- Consumido com `@Environment(\.authenticationController) private var authenticationController`.

### Persistência de sessão
- **Tokens:** `Keychain<T: Codable>` (wrapper genérico do Security framework).
- **Chaves:** **sempre** usar `Constants.Keys` (`accessToken`, `refreshToken`, `isAuthenticated`) — nunca strings literais.
- **Flag de sessão:** `@AppStorage(Constants.Keys.isAuthenticated)`.
- **Expiração:** `JWTDecoder.isExpired(token:)` decodifica o payload JWT (base64url) e compara `exp`.
- **Segurança:** nunca fazer `print` de tokens, payloads JWT ou credenciais.

### `ErrorState` — erros globais
`@Observable class ErrorState { var error: Error? }` injetado no `PlatziApp` via `.environment(errorState)`, com alert global via modificador `.globalErrorAlert()` (definido em `Errors/ErrorState.swift`).
- Nas telas: `@Environment(ErrorState.self) private var errorState` e, no `catch`, `errorState.error = error`.
- Conteúdo de `.sheet` precisa do próprio `.globalErrorAlert()` (alert do root não apresenta sobre sheets).

## 5. Convenções de Tela (SwiftUI)

Padrão consistente em todas as `*Screen`:

```swift
struct ExampleScreen: View {
    @State private var viewModel = ExampleViewModel()
    @State private var showSheet: Bool = false

    @Environment(ErrorState.self) private var errorState

    private func loadData() async {
        do {
            try await viewModel.loadItems()
        } catch {
            errorState.error = error
        }
    }

    var body: some View {
        ZStack {
            if viewModel.items.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("No items", systemImage: "shippingbox")
            } else {
                List(viewModel.items) { item in
                    NavigationLink { DetailScreen(item: item) } label: {
                        CellView(item: item)
                    }
                }
            }
        }
        .overlay(alignment: .center) { if viewModel.isLoading { ProgressView("Loading...") } }
        .task { await loadData() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") { showSheet = true }
            }
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                AddScreen { viewModel.add($0) }
            }
            .globalErrorAlert()
        }
        .navigationTitle("Title")
    }
}

#Preview {
    NavigationStack { ExampleScreen() }
        .environment(ErrorState())
}
```

### Padrões-chave
- **Loading:** `isLoading` no ViewModel (com `defer { isLoading = false }`); tela mostra `ProgressView` em `.overlay`.
- **Carregamento:** `.task { await load() }`; pull-to-refresh via `.refreshable`.
- **Estado vazio:** `ContentUnavailableView`.
- **Erros:** VM lança; a tela captura no `catch` e atribui `errorState.error = error` (alert global via `ErrorState`). Nunca engolir erros com `print`.
- **Navegação:** `NavigationStack` + `NavigationLink`; modais via `.sheet` sempre envoltos em `NavigationStack`.
- **Chamar async de callbacks síncronos:** `Button("Save") { Task { await save() } }`.
- **Callbacks entre telas:** closures `let onSave: (Product) -> Void` passados no `init`; a tela pai insere no seu VM.
- **Toolbar:** `ToolbarItem(placement: .topBarTrailing)`.
- **Preview:** **sempre** incluir `#Preview` injetando `.environment(ErrorState())` quando a tela usa o error state.
- **`.task`:** nunca aninhar `Task { }` dentro de `.task { }` — chame `await` direto (preserva cancelamento automático).
- **Botões primários:** `.buttonStyle(.glassProminent)` + `.controlSize(.large)` (Liquid Glass); campos de auth usam o componente `AuthField`.

### Componentes de UI reutilizáveis
- `CategoryCellView`, `ProductCellView` — células de lista com `AsyncImage`.
- `ImagePlaceHolderView` — placeholder de imagem (usado no `placeholder:` do `AsyncImage`).
- `ValidationSummaryView` — lista de erros de validação em vermelho.
- `AuthField` — campo com ícone e fundo arredondado, usado nas telas de auth.

### Validação de formulário
- Propriedade computada `isFormValid: Bool` **no ViewModel**.
- Botão de submit com `.disabled(!viewModel.isFormValid || viewModel.isLoading)`.
- Helpers em `String+Extensions`: `isEmptyOrWhitespace`, `isValidPassword`, `isEmail`.

## 6. Models e DTOs

- **`Models/`** — tipos de domínio consumidos pelas views: `Category`, `Product`, `Location`. Adotam `Codable` + `Identifiable` (e `Hashable` quando usados em navegação/seleção). Derivações via propriedades computadas (ex.: `Location.coordinate: CLLocationCoordinate2D`). Dados de preview via `static var preview`.
- **`DTOs/`** — tipos de transporte da API: `LoginRequest`/`LoginResponse`, `CreateProductRequest`, `RefreshTokenResponse`, `ErrorResponse`, etc. Um arquivo por tipo.
- Mapear snake_case da API com `CodingKeys` privado:
  ```swift
  private enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
      case refreshToken = "refresh_token"
  }
  ```

## 7. Tratamento de Erros

`NetworkError` conforma a `LocalizedError` com `errorDescription` localizado (`NSLocalizedString`). O caso `.undefined(Data, HTTPURLResponse)` tenta decodificar `ErrorResponse { message }` para exibir a mensagem da API.

Ao criar novos erros, siga o mesmo padrão: `enum` de erro + extensão `LocalizedError`. A exibição ao usuário é feita pelo `ErrorState` + `.globalErrorAlert()` (ver seção 4).

## 8. Estilo de Código

- **Nomes:** `PascalCase` para tipos; `camelCase` para propriedades/métodos.
- **Propriedades:** `@State private var` para estado de view; `let` para constantes.
- **Indentação:** 4 espaços.
- **Imports:** no topo, simples (`SwiftUI`, `Foundation`, `MapKit`).
- **Tipagem:** aproveitar o sistema de tipos; evitar force-unwrap (exceto `URL(string:)!` de constantes conhecidas, padrão já usado no projeto).
- **Comentários:** apenas para lógica não óbvia.
- **Concorrência:** `async`/`await`; nada de Combine.

## 9. Testes

- **Unitários:** framework **Testing** (`import Testing`, `@Test`, `#expect`) — não XCTest.
- **UI:** framework **XCUIAutomation**.

## 10. Checklist para Novas Features

1. [ ] URL adicionada em `Constants.Urls`.
2. [ ] Request/response em `DTOs/`; modelo de domínio em `Models/` (com `CodingKeys` se snake_case).
3. [ ] Método stateless em `PlatziService` (domínio) ou `AuthenticationController` (auth), retornando valor.
4. [ ] ViewModel em `ViewModels/` (`@MainActor @Observable`, DI via `init` com default, métodos `throws`).
5. [ ] Tela em `Screens/` com sufixo `Screen` consumindo o VM; componentes em `Views/`.
6. [ ] Estados de loading (`ProgressView`) e vazio (`ContentUnavailableView`).
7. [ ] Carregamento via `.task` (sem `Task` aninhado); validação via `viewModel.isFormValid` + `.disabled`.
8. [ ] `#Preview` com `.environment(ErrorState())` quando aplicável.
9. [ ] Erros no `catch` da tela → `errorState.error = error`; usar `NetworkError`/`LocalizedError` para novos erros; sem `print` de erros ou tokens.
10. [ ] Build via `BuildProject`; validação rápida via `XcodeRefreshCodeIssuesInFile`.
