# Frota360

**Checklist inteligente para inspeção preventiva de veículos**

Aplicativo mobile desenvolvido em **Flutter (Dart)** para a disciplina de Programação para Dispositivos Móveis. O usuário escolhe um carro, responde a um checklist de itens de segurança, registra as avarias encontradas e acompanha a condição do veículo por um **percentual de saúde** e por um **status** (Disponível, Atenção ou Restrição).

> Esta versão é um **MVP acadêmico**: todos os dados ficam na memória do aplicativo e são perdidos quando ele é fechado.

---

## Sobre o projeto

Checklists feitos em papel ou planilha geram registros dispersos e dificultam o acompanhamento do estado dos veículos. O Frota360 organiza as inspeções, guarda o histórico de cada carro e mostra rapidamente a situação atual da frota.

**Público-alvo:** frotas de empresas, órgãos e instituições que usam carros de serviço, pequenas frotas e responsáveis por veículos que precisam manter um histórico organizado das inspeções.

## Funcionalidades

**Implementadas nesta versão**

- Login simulado (aceita qualquer usuário e senha preenchidos)
- Dashboard com a contagem de veículos por situação e os últimos checklists
- Lista de veículos com busca por código, modelo ou placa
- Detalhes do veículo com dados, saúde em percentual e status
- Checklist com 6 itens, cada um classificado como **Normal**, **Atenção** ou **Crítico**
- Registro de avaria (gravidade e descrição) para itens em Atenção ou Crítico
- Resumo do checklist com a contagem de itens e a situação do veículo
- Histórico de checklists por veículo

**Fora do escopo desta versão**

Leitura de QR Code, foto da avaria, cadastro de novos carros, alerta de recorrência de problemas, menu lateral, tela de perfil e persistência dos dados.

## Fluxo do aplicativo

```
Login → Dashboard → Lista de veículos → Detalhes → Checklist → Avaria (se houver) → Resumo → Finalizar
```

1. **Login:** o usuário informa nome e senha e entra.
2. **Dashboard:** vê o resumo da frota e clica em *Novo Checklist*.
3. **Lista de veículos:** busca e escolhe um carro.
4. **Detalhes:** vê a saúde do veículo e clica em *Iniciar Checklist*.
5. **Checklist:** avalia cada item. Ao marcar *Atenção* ou *Crítico*, abre a tela de registrar avaria.
6. **Resumo:** confere o resultado e clica em *Finalizar*.
7. O checklist entra no histórico, e a saúde e o status do veículo são atualizados.

## Regras de negócio

### Itens do checklist

Pneus, Freios, Luzes (faróis, setas, lanternas), Óleo do motor, Bateria e Nível de água do radiador.

### Situação de um checklist

- Se existe pelo menos um item **Crítico**, a situação é **Crítico**.
- Senão, se existe pelo menos um item **Atenção**, a situação é **Atenção**.
- Senão, a situação é **Normal**.

### Status do veículo

É a situação do checklist **mais recente**:

| Situação do checklist | Status exibido |
|---|---|
| Normal | Disponível |
| Atenção | Atenção |
| Crítico | Restrição |

Um veículo sem checklist aparece como *Disponível*.

### Saúde do veículo (percentual)

Cada item vale **100** pontos se Normal, **50** se Atenção e **0** se Crítico. A saúde é a média desses pontos, arredondada:

```
saúde = (normais × 100 + atenções × 50) ÷ total de itens
```

**Exemplo (VTR-002):** 4 itens Normal, 1 Atenção (Freios) e 1 Crítico (Pneus) → (400 + 50) ÷ 6 = **75%**. Um veículo sem checklist tem saúde de 100%.

### Mensagens do resumo

- **Crítico:** não recomendado para utilização, com manutenção antes da liberação.
- **Atenção:** utilização com acompanhamento.
- **Normal:** veículo liberado.

> Essa classificação serve para demonstração e organização dos registros. Ela não substitui a avaliação de um profissional de manutenção.

## Tecnologias

| Tecnologia | Uso |
|---|---|
| Flutter e Dart (versão 3 ou mais nova) | Interface e lógica do aplicativo |
| Material 3 | Componentes visuais (tema azul) |
| Navigator | Navegação entre as telas |

O projeto **não usa nenhum pacote externo** além do próprio Flutter.

## Estrutura do projeto

Todo o código fica na pasta `lib`:

| Arquivo | Conteúdo |
|---|---|
| `main.dart` | Ponto de entrada do app, tema e tela de login |
| `models.dart` | Classes de dados, regras de cálculo, itens do checklist e dados de exemplo |
| `telas.dart` | Dashboard, lista de veículos, detalhes, checklist, registrar avaria e resumo |

### Telas

| Tela | Classe | Descrição |
|---|---|---|
| Login | `LoginPage` | Usuário e senha, com botão para mostrar ou esconder a senha |
| Dashboard | `DashboardPage` | Cards com total, disponíveis, em atenção e com restrição, botão *Novo Checklist* e últimos 3 checklists |
| Lista de veículos | `ListaVeiculosPage` | Busca em tempo real e etiqueta de status em cada carro |
| Detalhes | `DetalhesPage` | Modelo, placa, ano, km, indicador circular de saúde e histórico |
| Checklist | `ChecklistPage` | Um card por item, com opções Normal, Atenção e Crítico |
| Registrar avaria | `AvariaPage` | Escolha da gravidade (Atenção ou Crítico) e descrição do problema |
| Resumo | `ResumoPage` | Contadores de itens e mensagem sobre a situação do veículo |

A classe `StatusTag` é a etiqueta colorida reaproveitada em várias telas.

### Modelo de dados

- **`Gravidade`** (enum): `normal`, `atencao` e `critico`, associadas às cores verde, laranja e vermelho.
- **`Checklist`**: `data`, `autor`, `respostas` (mapa de item para gravidade) e `avarias` (mapa de item para descrição).
- **`Veiculo`**: `codigo`, `modelo`, `placa`, `ano`, `km` e `historico` (lista de checklists, com o mais novo na posição 0).
- **Dados globais**: `veiculos` (5 carros de exemplo, de VTR-001 a VTR-005), `itensChecklist`, `usuarioLogado` e a função `carregarExemplo()`, que cria um checklist inicial para o VTR-002 para o dashboard não começar vazio.

## Como executar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (Dart 3 ou mais novo)
- Um emulador Android ou um celular conectado
- Android Studio ou VS Code com a extensão do Flutter

> **Atenção (Windows):** salve o projeto em um caminho **sem acentos nem caracteres especiais**, como `C:\projetos\frota360`. Caso contrário, o Gradle falha ao compilar com o erro *"Your project path contains non-ASCII characters"*.

### Passo a passo

**Opção 1: clonando este repositório**

```bash
git clone https://github.com/SEU_USUARIO/frota360.git
cd frota360
flutter pub get
flutter run
```

**Opção 2: criando um projeto novo e copiando os arquivos**

1. Crie o projeto: `flutter create frota360`
2. Substitua o conteúdo da pasta `lib` pelos 3 arquivos do Frota360 (`main.dart`, `models.dart` e `telas.dart`).
3. Dentro da pasta do projeto, rode `flutter run`.

Não é preciso alterar o `pubspec.yaml`.

### Como testar

- **Login:** use qualquer usuário e senha, desde que os dois campos estejam preenchidos.
- **Dados de exemplo:** o veículo **VTR-002 (Renault Duster)** já vem com um checklist feito (Pneus crítico e Freios em atenção), para você ver o histórico e as cores de status sem preencher nada.
- **Fluxo completo:** Dashboard → *Novo Checklist* → escolha um carro → *Iniciar Checklist* → avalie os itens → *Ver resumo* → *Finalizar*.

## Detalhes de implementação

- **Estado:** as telas que mudam usam `StatefulWidget` e `setState`.
- **Navegação:** `Navigator.push` e `Navigator.pop`. Ao voltar de uma tela, as anteriores chamam `setState` para mostrar os dados atualizados.
- **Retorno entre telas:** a `AvariaPage` devolve a gravidade e a descrição, e a `ResumoPage` devolve `true` ao finalizar ou `false` ao voltar.
- **Checklist em edição:** só é salvo no histórico do veículo quando o usuário clica em *Finalizar*. Voltar do resumo não grava nada.

## Limitações conhecidas

- Os dados não são salvos: ao fechar o app, os checklists feitos voltam ao estado inicial.
- O login não valida credenciais.
- Não há cadastro de novos veículos nem foto das avarias.

## Evoluções futuras

- Leitura de QR Code para abrir o veículo direto
- Foto da avaria com a câmera
- Cadastro e edição de veículos
- Alerta de recorrência de problemas
- Histórico de avarias separado, menu lateral e tela de perfil
- Salvar os dados no aparelho ou em um banco de dados
- Relatórios em PDF e notificações

## Equipe

- Marcos Rodrigues Pantoja Filho
- Eduardo Fellipe Ramos Xavier
- Juliane Iomery Lima Casé
- Samara Messias

---

*Projeto acadêmico desenvolvido para a disciplina de Programação para Dispositivos Móveis. A classificação de gravidade é uma regra de demonstração do aplicativo e não substitui a avaliação de um profissional de manutenção.*
