
# Driving Profits

Driving Profits é um aplicativo móvel criado em Flutter para motoristas que desejam controlar ganhos, despesas e calcular o lucro líquido. O projeto usa um banco local (SQLite via sqflite) para persistência, adota o padrão Provider para gerenciamento de estado e oferece visualizações simples de resumo financeiro.

## Visão de negócio

Driving Profits é destinado a motoristas de aplicativos que precisam registrar rapidamente o início e fim de jornadas, acompanhar ganhos (corridas + gorjetas), registrar despesas (combustível, alimentação, higienização, outros) e obter métricas úteis como lucro líquido diário, total mensal, média por km e quilometragem total.

Problema que resolve:
- Evita perda de controle financeiro manual em anotações físicas;
- Ajuda a entender se dirigir em determinado dia/turno foi lucrativo;
- Permite analisar tendências mensais e tomar decisões (ex.: quando reduzir horas ou revistar rotas).

Público-alvo: motoristas de apps de transporte/entregas que buscam controle financeiro simples e offline.

## Principais features

- Iniciar e encerrar sessão de trabalho (registro de horário e quilometragem);
- Registrar ganhos da plataforma e gorjetas;
- Registrar despesas: combustível, alimentação, limpeza e outros custos;
- Cálculo automático de: total de ganhos, total de despesas e lucro líquido;
- Listagem por dia e filtros por mês;
- Métricas agregadas: total de km percorridos, média de ganho por km, lucro mensal;

## Arquitetura e organização do código

Estrutura principal (resumida):

- lib/
	- main.dart — ponto de entrada, configura Providers e temas;
	- models/ — modelos de domínio (por exemplo, `DailyEntry`);
	- data/services/ — comunicação com a camada de persistência (SQLite);
	- data/repositories/ — classes que expõem operações CRUD a partir dos serviços;
	- providers/ / ui/feature/ — ViewModels e Widgets que compõem a interface; provedor de estado usa `provider`/`ChangeNotifier`;
	- l10n/ — arquivos de localização (gen_l10n);

Modelo central: `DailyEntry` (em `lib/models/daily_entry.dart`) com campos:
- id, date, endDate, startTime, endTime
- uberEarnings, tips
- fuelCost, foodCost, cleaningCost, otherCosts
- kmStart, kmEnd
- status (EntryStatus: none, open, closed)

Repositório e persistência:
- Utiliza `sqflite` e `path_provider` para armazenar um banco local `trackerDb.db`.
- `EntryRepository` contém métodos para inserir, buscar (por mês), atualizar e deletar registros.

Gerenciamento de estado:
- `provider` com `ChangeNotifier` para `EntryProvider`, `SummaryViewmodel`, `DailyListViewmodel` e `ExpenseViewModel`.

Temas:
- O app inclui temas claros e escuros personalizados em `ui/theme` (por exemplo `AltSoftTheme` e `AltSoftDarkTheme`).

## Stack técnica

- Flutter (SDK >= 3.9.0)
- Linguagem: Dart
- Persistência local: sqflite
- Gerenciamento de estado: provider
- Internacionalização: Flutter gen_l10n (flutter_localizations, intl)
- Visualizações: fl_chart
- Outras dependências: path_provider, uuid, shimmer, flutter_animate

Dependências encontradas em `pubspec.yaml` (resumo):
- cupertino_icons, sqflite, path_provider, provider, intl, fl_chart, uuid, flutter_animate, shimmer

## Requisitos

- Flutter instalado (compatível com o SDK definido em `pubspec.yaml`, ex: Dart/Flutter 3.9+)
- Android SDK / Xcode para compilar em dispositivos Android/iOS

## Execução (desenvolvimento)

1. Instale as dependências do Flutter e ferramentas ( Flutter SDK, Android SDK ).
2. No diretório do projeto rode:

```powershell
flutter pub get
```

3. Para executar no emulador ou dispositivo Android conectado:

```powershell
flutter run -d <device-id>
```

4. Gerar localizações caso necessário (o projeto já inclui as geradas):

```powershell
flutter gen-l10n
```

## Build (release)

- Android (APK):

```powershell
flutter build apk --release
```

- iOS (agende via Xcode, veja docs do Flutter):

```powershell
flutter build ios --release
```

## Testes

Tem testes de widget básicos (pasta `test/`). Para executar:

```powershell
flutter test
```

## Contribuição

Contribuições são bem-vindas. Recomendações:

1. Abra uma issue descrevendo a mudança desejada ou bug;
2. Abra um fork e crie uma branch com nome descritivo (ex: feature/ajustar-db);
3. Certifique-se de rodar `flutter format` e testes antes de enviar o PR;
4. Inclua screenshots e descrições nas PRs para alterações visuais.

Áreas de interesse para PRs iniciais:
- Melhorias na UI/UX do fluxo de iniciar/encerrar sessão;
- Exportação/backup dos dados (CSV/JSON);
- Sincronização opcional com nuvem (ex: Google Drive / Firebase);
- Melhorias nas métricas e novos gráficos.

## Considerações sobre dados e privacidade

- Todos os dados são armazenados localmente no dispositivo (não há envio remoto por padrão).
- Se implementar sincronização na nuvem, adicione avisos de privacidade e opções de exportação/remoção de dados.

## Próximos passos sugeridos

- Adicionar badges (build, cobertura, lint) ao README.
- Configurar CI (GitHub Actions) para executar `flutter test` e `flutter analyze`.
- Adicionar exemplos/screenshots na pasta `assets/` e anexá-los ao README.
- Implementar exportação/importação de backup e testes automatizados para o repositório de dados.

## Contato

Se precisar de ajuda com o código, crie uma issue neste repositório ou entre em contato com o mantenedor no perfil do GitHub.

---

README gerado automaticamente com base no estado atual do código em `lib/` e `pubspec.yaml`.
