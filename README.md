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
├── .dart_tool/                   # Ferramentas internas do Flutter/Dart
├── .flutter-plugins-dependencies # Plugins usados pelo Flutter
├── .git/                         # Dados do controle de versão Git
├── .gitignore                    # Arquivos/pastas ignorados pelo Git
├── .metadata                     # Metadados do projeto Flutter
├── .vscode/                      # Configurações do VS Code (opcional)
├── analysis_options.yaml         # Regras de análise estática do Dart
├── android/                      # Projeto Android nativo
├── assets/                       # Imagens e recursos visuais
│   ├── images/                   # Imagens utilizadas no app
├── build/                        # Arquivos gerados na build
├── firebase.json                 # Configuração do Firebase para web
├── ios/                          # Projeto iOS nativo
├── lib/                          # Código-fonte principal do app
│   ├── app.dart                  # Configuração principal do app
│   ├── firebase_options.dart     # Opções de inicialização do Firebase
│   ├── main.dart                 # Ponto de entrada do app
│   ├── screens/                  # Telas do aplicativo
│   │   ├── home_idoso.dart                 # Tela principal do idoso
│   │   ├── home_responsavel.dart           # Tela principal do responsável
│   │   ├── idoso_info.dart                 # Tela para adicionar infos do idoso
│   │   ├── idoso_page.dart                 # Tela do Idoso para o responsável
│   │   ├── login.dart                      # Tela de login
│   │   ├── medicamentos.dart               # Tela para mostrar medicamentos cadastrados
│   │   ├── register_codigo_idoso.dart      # Tela para vincular responsável com idoso
│   │   ├── register_idoso_resto.dart       # Complemento de cadastro do Idoso
│   │   ├── register_idoso.dart             # Registro de idoso
│   │   ├── register_medicamentos.dart      # Registro dos medicamentos
│   │   ├── register_principal.dart         # Escolha de tipo de registro
│   │   ├── register_responsavel.dart       # Registro de responsável
│   │   ├── register_responsavel_resto.dart # Complemento de cadastro do responsável
│   │   └── welcome.dart                    # Tela de boas-vindas
│   ├── services/                # Lógica de autenticação e banco
│   │   ├── auth_service.dart             # Serviço de autenticação (login, registro, Google)
│   │   └── firestore_service.dart        # Serviço de banco de dados (Firestore)
│   └── widgets/                 # Componentes reutilizáveis
├── LICENSE                      # Licença do projeto
├── linux/                       # Projeto Linux nativo
├── macos/                       # Projeto macOS nativo
├── pubspec.lock                 # Versões travadas das dependências
├── pubspec.yaml                 # Dependências e configurações do Flutter
├── README.md                    # Documentação principal
├── test/                        # Testes automatizados
├── web/                         # Projeto web e recursos
├── windows/                     # Projeto Windows nativo
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

Faço o desenvolvimento principalmente no Backend (Arquitetura, Banco de dados e Autenticação) do **Lembrar+** em **macOS** e **Windows**, utilizando o editor de código **VSCode** com suporte a Flutter/Dart.  
Para testes, utilizo emuladores Android/iOS e um dispositivo físico Android.  
O controle de versão é feito pelo **Git** diretamente pelo terminal integrado do VSCode.

---
### 📄 Licença

Este projeto está sob a Apache License 2.0.
