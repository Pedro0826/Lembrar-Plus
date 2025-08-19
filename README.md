# Lembrar+ 🌟

[![License](https://img.shields.io/badge/license-Apache%202.0-blue)]()

Este repositório contém o aplicativo **Lembrar+**, desenvolvido em Flutter (Dart), voltado para ajudar idosos a se comunicarem com seus responsáveis.  
O app oferece funcionalidades de **login**, **registro**, **chamadas**, **mensagens** e **avisos rápidos** entre idoso e responsável.

---

## Funcionalidades

- Login e registro de usuários (*Idoso* ou *Responsável*).  
- Tela inicial de boas-vindas.  
- Comunicação entre idoso e responsável:  
  - Ligar  
  - Enviar mensagens  
  - Enviar alertas/notificações  
- Histórico de interações.

---

## Tecnologias

- Flutter (Dart)  
- Android & iOS  

---

## Como usar

Antes de começar, certifique-se de ter:

- Flutter instalado ([instruções aqui](https://docs.flutter.dev/get-started/install))  
- Emulador ou dispositivo Android/iOS  

### Passos:

```bash
git clone https://github.com/ICEI-PUC-Minas-EC-TI/plu-ti1-2025-2-t1-g1-lembrar
cd lembrar-plus
```
**Instale as dependências:**
```bash
flutter pub get
```
**Execute o app:**
```bash
flutter run
```

---

## Estrutura do Repositório

- **README.md**: este é o arquivo que você está lendo agora.
- **LICENSE**: este arquivo contém a licença do projeto.
- **pubspec.yaml**: contém as definições do Flutter, dependências e configurações do projeto.
- **lib/**: contém todo o código-fonte do aplicativo, organizado da seguinte forma:
  - **main.dart**: ponto de entrada do aplicativo.
  - **screens/**: todas as telas do app:
    - **welcome.dart**: tela de boas-vindas inicial.
    - **login.dart**: tela de login de usuário (idoso ou responsável).
    - **register.dart**: tela de registro de novo usuário.
    - **home_idoso.dart**: tela principal do idoso após login.
    - **home_responsavel.dart**: tela principal do responsável após login.
  - **widgets/**: componentes visuais reutilizáveis, como botões, cards e alertas.
  - **services/**: lógica do app, funções auxiliares e, futuramente, integração com backend.
- **assets/**: imagens, ícones, fontes e outros recursos visuais do aplicativo.
- **test/**: contém testes unitários do aplicativo para garantir que as funcionalidades se comportam conforme esperado.
- **android/**: código e configuração específicos do Android, incluindo Gradle, manifest e recursos nativos.
- **ios/**: código e configuração específicos do iOS, incluindo Info.plist, Xcode project e recursos nativos.
- **.gitignore**: lista de arquivos e pastas que o Git deve ignorar, como builds e caches.
- **.vscode/**: configurações do VS Code para o projeto (opcional).


---

## Ferramentas Utilizadas

### [Caua Diniz] 

### [Júlia de Mello]

### [Pedro Vitor](https://github.com/Pedro0826)

Faço o desenvolvimento do **Lembrar+** em **macOS** e Windows**, utilizando o editor de código **VSCode** com suporte a Flutter/Dart.  
Para testes, utilizo emuladores Android/iOS e um dispositivo físico Android.  
O controle de versão é feito pelo **Git** diretamente pelo terminal integrado do VSCode.

---

### Licença

Este projeto está sob a Apache License 2.0.

---

