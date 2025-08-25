# 🌟 Lembrar+

[![License](https://img.shields.io/badge/license-Apache%202.0-blue)]()

Este repositório contém o aplicativo **Lembrar+**, desenvolvido em Flutter (Dart), voltado para ajudar idosos a se comunicarem com seus responsáveis. O app oferece funcionalidades de **login**, **registro**, **chamadas**, **mensagens** e **avisos rápidos** entre idoso e responsável.

## 🧩 Funcionalidades

- Login e registro de usuários (*Paciente* ou *Cuidador*).  
- Tela inicial de boas-vindas.  
- Comunicação entre idoso e responsável:  
  - Ligar  
  - Enviar mensagens  
  - Enviar alertas/notificações  
- Histórico de interações.

## ⚙️ Tecnologias

- Flutter (Dart)  
- Android & iOS  

## 🚀 Como Usar

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
## 🗂️ Estrutura do Repositório

```
lembrar-plus/
├── README.md                     # Documentação principal do projeto
├── LICENSE                       # Licença do projeto (Apache 2.0)
├── pubspec.yaml                  # Definições do Flutter, dependências e configurações
├── lib/                          # Código-fonte do aplicativo
│   ├── main.dart                 # Ponto de entrada do aplicativo
│   ├── screens/                  # Telas do app
│   │   ├── welcome.dart          # Tela de boas-vindas inicial
│   │   ├── login.dart            # Tela de login de usuário (idoso ou responsável)
│   │   ├── register.dart         # Tela de registro de novo usuário
│   │   ├── home_idoso.dart       # Tela principal do idoso após login
│   │   └── home_responsavel.dart # Tela principal do responsável após login
│   ├── widgets/                  # Componentes visuais reutilizáveis (botões, cards, alertas)
│   └── services/                 # Lógica do app e futura integração com backend
├── assets/                       # Imagens, ícones, fontes e recursos visuais
├── test/                         # Testes unitários do aplicativo
├── android/                      # Código e configurações específicas do Android (Gradle, manifest, recursos nativos)
├── ios/                          # Código e configurações específicas do iOS (Info.plist, Xcode project, recursos nativos)
├── .gitignore                    # Arquivos e pastas ignorados pelo Git (builds, caches, etc.)
└── .vscode/                      # Configurações do VS Code para o projeto (opcional)
```
---
## 👩‍💻 Autores

### [Caua Diniz](https://github.com/Caua0305)

Realizo um pouco de ambos os campos do **Lembrar+**, tanto do Frontend quanto no Backend em **macOS** por meio do **VSCode**, dando apoio criativo para o desenvolvimento das telas como também ajudando na construção do código-fonte, utilizando de emuladores como o **Android Studio**.
Também dou suporte acerca da colaboração nas tarefas de integração entre as camadas do sistema.
Apoio nos testes e validações do sistema.

### [Júlia de Mello](https://github.com/jujupoipo)

Atuo principalmente no Frontend do Lembrar+ em **Windows** pelo **VSCode**, desenvolvendo e mantendo a interface do usuário em Flutter, com foco na usabilidade e na estética do aplicativo.
Participo da definição de wireframes e protótipos para as telas, além de contribuir no planejamento do projeto, organizando tarefas, cronograma e documentação.
Também ofereço suporte pontual no backend quando necessário, garantindo integração consistente entre as camadas do sistema.

### [Pedro Vitor](https://github.com/Pedro0826)

Faço o desenvolvimento do **Lembrar+** em **macOS** e **Windows**, utilizando o editor de código **VSCode** com suporte a Flutter/Dart.  
Para testes, utilizo emuladores Android/iOS e um dispositivo físico Android.  
O controle de versão é feito pelo **Git** diretamente pelo terminal integrado do VSCode.

---
### 📄 Licença

Este projeto está sob a Apache License 2.0.
