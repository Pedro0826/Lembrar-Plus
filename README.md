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

📦 lembrar-plus
┣ 📜 README.md — este é o arquivo que você está lendo agora
┣ 📜 LICENSE — contém a licença do projeto
┣ 📜 pubspec.yaml — definições do Flutter, dependências e configurações do projeto
┣ 📂 lib/ — código-fonte do aplicativo
┃ ┣ 📜 main.dart — ponto de entrada do aplicativo
┃ ┣ 📂 screens/ — telas do app
┃ ┃ ┣ 📜 welcome.dart — tela de boas-vindas inicial
┃ ┃ ┣ 📜 login.dart — tela de login de usuário (idoso ou responsável)
┃ ┃ ┣ 📜 register.dart — tela de registro de novo usuário
┃ ┃ ┣ 📜 home_idoso.dart — tela principal do idoso após login
┃ ┃ ┗ 📜 home_responsavel.dart — tela principal do responsável após login
┃ ┣ 📂 widgets/ — componentes visuais reutilizáveis (botões, cards, alertas)
┃ ┗ 📂 services/ — lógica do app e futura integração com backend
┣ 📂 assets/ — imagens, ícones, fontes e recursos visuais
┣ 📂 test/ — testes unitários do aplicativo
┣ 📂 android/ — código e configurações específicas do Android (Gradle, manifest, recursos nativos)
┣ 📂 ios/ — código e configurações específicas do iOS (Info.plist, Xcode project, recursos nativos)
┣ 📜 .gitignore — arquivos e pastas ignorados pelo Git (builds, caches, etc.)
┗ 📂 .vscode/ — configurações do VS Code para o projeto (opcional)

---

## Ferramentas Utilizadas

### [Caua Diniz] 

### [Júlia de Mello](https://github.com/jujupoipo)

Atuo principalmente no Frontend do Lembrar+, desenvolvendo e mantendo a interface do usuário em Flutter, com foco na usabilidade e na estética do aplicativo.
Participo da definição de wireframes e protótipos para as telas, além de contribuir no planejamento do projeto, organizando tarefas, cronograma e documentação.
Também ofereço suporte pontual no backend quando necessário, garantindo integração consistente entre as camadas do sistema.

### [Pedro Vitor](https://github.com/Pedro0826)

Faço o desenvolvimento do **Lembrar+** em **macOS** e Windows**, utilizando o editor de código **VSCode** com suporte a Flutter/Dart.  
Para testes, utilizo emuladores Android/iOS e um dispositivo físico Android.  
O controle de versão é feito pelo **Git** diretamente pelo terminal integrado do VSCode.

---

### Licença

Este projeto está sob a Apache License 2.0.

---

