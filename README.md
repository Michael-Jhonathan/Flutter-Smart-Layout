# Smart Layout — Guia Completo de Uso

Sistema de layout responsivo standalone para Flutter composto por dois arquivos independentes.
Nenhuma dependência externa necessária — basta copiar os arquivos para o projeto.

## Instalação

Como este pacote é autônomo, você pode adicioná-lo ao seu projeto Flutter referenciando diretamente o repositório no GitHub ou o caminho local.

### 1. Via GitHub (Recomendado)
Adicione ao seu `pubspec.yaml`:
```yaml
dependencies:
  smart_layout:
    git:
      url: https://github.com/Michael-Jhonathan/smart_layout.git
```

### 2. Via Caminho Local
Se você baixou a pasta do pacote para a sua máquina:
```yaml
dependencies:
  smart_layout:
    path: ../caminho/para/smart_layout
```

### Importação
Depois de rodar `flutter pub get`, você pode importar todos os componentes de uma vez no seu código:

```dart
import 'package:smart_layout/smart_layout.dart';
```

---

## Filosofia de uso conjunto

```
ResponsiveBox   → define ONDE cada coisa fica (estrutura, colunas, linhas)
AutoElement     → define O TAMANHO que cada coisa tem (escala de conteúdo)
```

```
Página
└── ResponsiveBox(row)              ← organiza 3 colunas lado a lado
    ├── AutoElement → CardA         ← conteúdo do card A escala junto
    ├── AutoElement → CardB
    └── AutoElement → CardC
```

---

---

# AutoElement

**Arquivo:** `auto_element.dart`

Widget que aplica escala dinâmica e contínua a todo o conteúdo filho — fontes, ícones, padding e dimensões — sem usar `Transform.scale`. O layout ao redor reage corretamente ao novo tamanho.

## Como funciona

O `AutoElement` compara a largura disponível com uma **largura de referência** — a largura da tela em que você desenvolveu/desenhou esse bloco.
Quando as duas coincidem, `scale = 1.0` e nada muda. Quando a tela é maior ou menor, o conteúdo cresce ou encolhe proporcionalmente.

A fórmula varia por zona:

| Situação | Fórmula | Comportamento |
|---|---|---|
| Tela **menor** que a referência | `0.75 + (rawScale × 0.25)` | Encolhe suavemente com piso em 0.75x — nunca fica ilegível |
| Tela **igual** à referência | `1.0` | Sem alteração — exatamente como você escreveu |
| Tela **maior** que a referência | `rawScale` (linear puro) | Cresce proporcionalmente, sem limite — 4K, 8K, qualquer resolução |

**Importante:** a largura usada é `constraints.maxWidth` (espaço real disponível para o widget), não a largura da tela inteira. Isso garante escala correta dentro de layouts divididos (ex: grid de 2 colunas).

## Pixels lógicos vs físicos — por que não quebra

Flutter trabalha com **pixels lógicos** (dp), não físicos. `MediaQuery.size.width` já retorna pixels lógicos:

```
pixels lógicos = pixels físicos / devicePixelRatio
```

Dois monitores Full HD (1920 físico):

| Monitor | Tamanho físico | DPI | devicePixelRatio | Pixels lógicos |
|---|---|---|---|---|
| Monitor 24" | grande | 96 DPI | ~1.0 | **1920 lógicos** |
| Notebook 13" | menor | 192 DPI | ~2.0 | **960 lógicos** |

O notebook menor e mais denso terá 960px lógicos → o `AutoElement` escala para baixo → o conteúdo aparece no **tamanho físico correto**, apenas mais nítido (mais pixels por centímetro). O código se comporta corretamente em ambos sem nenhuma configuração extra.

## Largura de referência — três níveis de controle

A prioridade é: **global** > **por-widget** > **padrão (1000px)**

### 1. Global (prioridade máxima)

Defina `kGlobalReferenceWidth` uma vez no início do app. Ele sobrepõe **tudo**:

```dart
void main() {
  kGlobalReferenceWidth = 1920; // toda a app usa Full HD como referência
  runApp(const MyApp());
}
```

Para desativar e voltar ao comportamento por-widget:
```dart
kGlobalReferenceWidth = null;
```

### 2. Por-widget (prioridade intermediária)

Cada `AutoElement` pode declarar sua própria referência, ignorada se `kGlobalReferenceWidth` estiver definido:

```dart
AutoElement(
  referenceWidth: 1440, // este bloco foi desenhado em 1440px
  child: MeuCard(),
)
```

### 3. Padrão (fallback)

Se nenhum dos dois estiver definido, usa `kDefaultReferenceWidth = 1000.0`:

```dart
const double kDefaultReferenceWidth = 1000.0; // pode ser alterado no arquivo
```

### Tabela de escala (referência = 1000px)

| Largura disponível (lógica) | Escala |
|---|---|
| 400px (mobile) | 0.85x |
| 600px (tablet pequeno) | 0.90x |
| 1000px (referência) | 1.00x |
| 1440px (monitor padrão) | 1.44x |
| 1920px (Full HD) | 1.92x |
| 3840px (4K) | 3.84x |
| 7680px (8K) | 7.68x |

## Parâmetros

| Parâmetro | Tipo | Obrigatório | Padrão | Descrição |
|---|---|---|---|---|
| `child` | `Widget` | Sim | — | Conteúdo a ser escalado |
| `referenceWidth` | `double` | Não | `kDefaultReferenceWidth` | Largura onde `scale = 1.0`. Ignorado se `kGlobalReferenceWidth` estiver definido |
| `margin` | `EdgeInsetsGeometry?` | Não | `null` | Margem externa — também é escalada proporcionalmente |
| `padding` | `EdgeInsetsGeometry?` | Não | `null` | Espaçamento interno — também é escalado proporcionalmente |
| `width` | `double?` | Não | `null` | Largura fixa (em pixels lógicos do design de referência) — escalada |
| `height` | `double?` | Não | `null` | Altura fixa — escalada |
| `backgroundColor` | `Color?` | Não | `null` | Cor de fundo simples |

## O que é escalado automaticamente

- **Texto:** via `MediaQuery.textScaler` — todo `Text` dentro do `AutoElement` escala sem nenhum código extra
- **Ícones:** via `IconTheme` — todo `Icon` dentro do `AutoElement` escala automaticamente
- **`padding` e `margin`** do próprio `AutoElement`: multiplicados pelo fator de escala
- **`width` e `height`** do próprio `AutoElement`: multiplicados pelo fator de escala

## O que NÃO é escalado automaticamente

- `Container`, `Padding` com valores hardcoded dentro de filhos complexos.
- `SizedBox` padrão (mas você pode usar `AutoGap` ou `AutoBox`, veja abaixo!)

## Espaçamentos e Caixas Manuais (AutoGap e AutoBox)

Se você precisa de um `SizedBox` para separar itens ou definir larguras fixas dentro de um `AutoElement`, use os widgets auxiliares fornecidos. Eles leem a escala pai e se ajustam sozinhos:

### AutoGap

O substituto perfeito para o `SizedBox(height: x)` em espaçamentos:

```dart
AutoElement(
  child: Column(
    children: [
      Text('Item 1'),
      AutoGap(24), // Equivale a SizedBox(height: 24, width: 24) que escala sozinho!
      Text('Item 2'),
    ],
  ),
)
```

### AutoBox

O substituto para o `SizedBox(width: x, height: y)` quando você precisa de uma caixa com dimensões exatas que escale:

```dart
AutoBox(
  width: 200,
  height: 80,
  child: MeuComponenteInterno(),
)
```

### Lendo a escala na mão (Avançado)

Se você estiver construindo um componente customizado complexo (ex: um painter ou raio de borda) e precisa saber qual a escala o `AutoElement` pai aplicou:

```dart
final double scale = AutoScale.of(context);
return Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12 * scale),
  ),
);
```

## Exemplos

### Básico — card com texto e botão escalando

```dart
AutoElement(
  margin: const EdgeInsets.all(24),
  padding: const EdgeInsets.all(32),
  backgroundColor: Colors.white,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.star, size: 48),           // escala automaticamente
      const Text(                                  // escala automaticamente
        'Titulo',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      const Text(
        'Descricao do card com texto mais longo.',
        style: TextStyle(fontSize: 16),
      ),
      ElevatedButton(
        onPressed: () {},
        child: const Text('Acao', style: TextStyle(fontSize: 16)),
      ),
    ],
  ),
)
```

### Dimensões fixas escaladas

```dart
// O AutoElement vai exibir um box de 300×200 no design de referência (1000px),
// mas em 2000px ele vai exibir 600×400, em 500px ele vai exibir ~225×150.
AutoElement(
  width: 300,
  height: 200,
  backgroundColor: Colors.blue,
  child: const Center(child: Text('Box escalado')),
)
```

### Dentro de layout dividido (correto)

```dart
// Em uma linha de 2 colunas, cada AutoElement recebe ~metade da tela.
// Ele usa esse espaço real para calcular a escala, não a tela inteira.
Row(
  children: [
    Expanded(
      child: AutoElement(
        padding: const EdgeInsets.all(16),
        child: const Text('Coluna esquerda', style: TextStyle(fontSize: 20)),
      ),
    ),
    Expanded(
      child: AutoElement(
        padding: const EdgeInsets.all(16),
        child: const Text('Coluna direita', style: TextStyle(fontSize: 20)),
      ),
    ),
  ],
)
```

### Usando `computeAutoScale` diretamente

```dart
// Para aplicar escala a valores que não são cobertos pelo AutoElement
LayoutBuilder(
  builder: (context, constraints) {
    final double scale = computeAutoScale(constraints.maxWidth);
    return Container(
      width: 120 * scale,
      height: 48 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12 * scale),
        color: Colors.indigo,
      ),
      child: const Center(
        child: Text('Botao', style: TextStyle(fontSize: 16)), // texto escala via AutoElement pai
      ),
    );
  },
)
```

---

---

# ResponsiveBox

**Arquivo:** `responsive_box.dart`

Substituto do `Row`, `Column` e `Container` com comportamento responsivo embutido.
Organiza filhos em linha, coluna ou stack, com quebra de linha automática, encolhimento seguro, scroll, flex, e dimensões em porcentagem de viewport.

## Widgets disponíveis

| Widget | Descrição |
|---|---|
| `ResponsiveBox` | Widget principal — layout adaptativo completo |
| `ResponsiveLayoutMode` | Enum: `row`, `column`, `stack` |
| `UniversalResponsiveLayout` | Builders diferentes para mobile / tablet / desktop |
| `UniversalResponsiveValueBuilder<T>` | Valor diferente por breakpoint, com builder |
| `ResponsiveValue<T>` | Encapsula um valor com variante por breakpoint |
| `ResponsiveGridLayout` | Grid com número de colunas adaptável por breakpoint |

## Breakpoints

| Nome | Largura |
|---|---|
| Mobile | < 600px |
| Tablet | >= 600px |
| Desktop | >= 1200px |

---

## ResponsiveBox — Referência Completa de Parâmetros

### Layout

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `child` | `Widget?` | `null` | Filho único. Exclusivo com `children` |
| `children` | `List<Widget>?` | `null` | Lista de filhos. Exclusivo com `child` |
| `layoutMode` | `ResponsiveLayoutMode` | `column` | `row` = horizontal, `column` = vertical, `stack` = empilhado |
| `wrap` | `bool?` | `null` | `null` = automático (ativa em row sem Expanded), `true` = sempre, `false` = nunca |
| `gap` | `double?` | `null` | Espaçamento automático que escala proporcionalmente. Dispensa SizedBox. |
| `gapReferenceWidth` | `double` | `1000.0` | Largura base (viewport) para calcular a proporção do gap. |
| `align` | `dynamic` | `null` | Alinhamento total (substitui Main e Cross). Veja a seção detalhada abaixo. |
| `mainAxisAlignment` | `MainAxisAlignment?` | `null` | Apenas para overrides muito específicos no eixo principal |

### Gaveta Mobile (Collapse)

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `collapseBreakpoint` | `double` | `600.0` | Abaixo dessa largura (px), itens com ResponsiveCollapse somem e geram menu. |
| `collapseIcon` | `Widget?` | `null` | Ícone do menu hamburguer. Padrão: `Icon(Icons.menu)` |
| `collapseIconPosition` | `ResponsiveCollapsePosition` | `end` | Define se o ícone do menu vai no início (`start`), no meio (`center`), ou final (`end`). |
| `onOpenCollapseMenu` | `Function?` | `null` | Intercepta o clique para abrir um menu customizado em vez do BottomSheet padrão. |

### 🎯 Alinhamento Simplificado (`align`)

O parâmetro `align` unifica todo o sistema complexo do Flutter (`MainAxisAlignment`, `CrossAxisAlignment`, `Stack Alignment`) em uma única propriedade absurdamente fácil de usar, inspirada no CSS.

Você pode passar **Strings**, **Records** ou o **Enum** `SmartAlign`. 

**Sintaxe por String (Recomendado)**
```dart
align: 'center'             // Centraliza os dois eixos
align: 'mid, start'         // Eixo Principal = Meio, Eixo Transversal = Início
align: 'between, stretch'   // Principal = Espaço Entre, Transversal = Esticado
```

**Valores e Atalhos Aceitos:**

| Enum `SmartAlign` | Atalho na String | Comportamento |
|---|---|---|
| `SmartAlign.start` | `'start'`, `'top'`, `'left'` | Gruda no início |
| `SmartAlign.center` | `'center'`, `'mid'` | Fica no meio |
| `SmartAlign.end` | `'end'`, `'bottom'`, `'right'` | Gruda no final |
| `SmartAlign.spaceBetween` | `'between'` | Espaço apenas *entre* os itens |
| `SmartAlign.spaceAround` | `'around'` | Espaço igual, mas metade nas pontas |
| `SmartAlign.spaceEvenly` | `'evenly'` | Espaço perfeitamente igual em tudo |
| `SmartAlign.stretch` | `'stretch'` | Estica para preencher o limite (Transversal) |

**Sintaxe Segura (Dart 3 Records):**
```dart
align: SmartAlign.center
align: (SmartAlign.spaceBetween, SmartAlign.start)
```

### 🍔 Responsive Collapse (Gaveta Automática)

Envolva qualquer widget do `ResponsiveBox` com `ResponsiveCollapse` e configure o `collapseBreakpoint`. Quando a tela ficar pequena (ex: Mobile), todos os itens "colapsáveis" sairão da tela automaticamente e gerarão um botão de Menu (Hamburger). Clicar no botão abrirá uma gaveta (BottomSheet) com os itens.

**Exemplo:**
```dart
ResponsiveBox(
  layoutMode: ResponsiveLayoutMode.row,
  collapseBreakpoint: 600, // Quando a tela for menor que 600px
  children: [
    Logo(),
    ResponsiveCollapse(
      child: Botao('Home'), // No desktop, mostra o botao pequeno
      collapsedChild: ListTile(title: Text('Home')), // Na gaveta (mobile), mostra um list tile largo!
    ),
    ResponsiveCollapse(
      child: Botao('Sobre'),
      collapsedChild: ListTile(title: Text('Sobre')),
    ),
    BotaoDeLogin(), // Este nunca some da tela!
  ],
)
```

### Overflow e Scroll

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `shrinkOnOverflow` | `bool` | `true` | Encolhe via `FittedBox.scaleDown` quando o conteúdo não cabe. Impede overflow sem scroll |
| `scaleToFit` | `bool` | `false` | Cresce E encolhe para preencher o espaço exatamente (`FittedBox.contain`) |
| `scaleUp` | `bool` | `false` | Permite crescer além do tamanho natural quando `shrinkOnOverflow: true` |
| `scrollable` | `bool` | `false` | Ativa scroll automático (vertical em column, horizontal em row) |

### Dimensões

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `width` | `double?` | `null` | Largura fixa em pixels lógicos |
| `height` | `double?` | `null` | Altura fixa em pixels lógicos |
| `maxWidth` | `double?` | `null` | Largura máxima em pixels lógicos |
| `minWidth` | `double?` | `null` | Largura mínima em pixels lógicos |
| `maxHeight` | `double?` | `null` | Altura máxima em pixels lógicos |
| `minHeight` | `double?` | `null` | Altura mínima em pixels lógicos |
| `widthPercent` | `double?` | `null` | Largura como fração da tela (0.0 a 1.0) |
| `heightPercent` | `double?` | `null` | Altura como fração da tela (0.0 a 1.0) |
| `maxWidthPercent` | `double?` | `null` | Largura máxima como fração da tela |
| `maxHeightPercent` | `double?` | `null` | Altura máxima como fração da tela |
| `fullWidth` | `bool` | `false` | Ocupa 100% da largura disponível |
| `fullHeight` | `bool` | `false` | Ocupa 100% da altura disponível |

### Espaçamento e Estilo

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `padding` | `EdgeInsetsGeometry?` | `null` | Espaçamento interno |
| `margin` | `EdgeInsetsGeometry` | `EdgeInsets.zero` | Margem externa |
| `backgroundColor` | `Color?` | `null` | Cor de fundo simples |
| `decoration` | `Decoration?` | `null` | Decoração completa (sobrepõe `backgroundColor`) |
| `alignment` | `AlignmentGeometry?` | `null` | Alinhamento absoluto do conteúdo dentro do espaço |

### Flex

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `flex` | `int?` | `null` | Fator de crescimento dentro de Row/Column pai (como `Flexible`) |
| `flexFit` | `FlexFit` | `FlexFit.loose` | `loose` = como `Flexible`, `tight` = como `Expanded` |

---

## Exemplos por caso de uso

### Linha que quebra automaticamente (row com wrap)

```dart
// Sem Expanded nos filhos → wrap é ativado automaticamente.
// Os cards se reorganizam em múltiplas linhas quando a tela encolhe.
ResponsiveBox(
  layoutMode: ResponsiveLayoutMode.row,
  // wrap: null  ← padrão, ativa automaticamente em row sem Expanded
  children: [
    CardA(),
    CardB(),
    CardC(),
    CardD(),
  ],
)
```

### Linha com divisão proporcional (flex)

```dart
// Dois painéis: esquerdo ocupa 1/3, direito ocupa 2/3.
// Usar wrap: false para forçar row mesmo sem wrap.
ResponsiveBox(
  layoutMode: ResponsiveLayoutMode.row,
  wrap: false,
  children: [
    ResponsiveBox(flex: 1, child: Sidebar()),
    ResponsiveBox(flex: 2, child: MainContent()),
  ],
)
```

### Coluna com scroll

```dart
ResponsiveBox(
  layoutMode: ResponsiveLayoutMode.column,
  scrollable: true,
  padding: const EdgeInsets.all(16),
  children: List.generate(20, (i) => ListItem(index: i)),
)
```

### Encolhimento seguro (padrão — sem configuração extra)

```dart
// shrinkOnOverflow: true é o padrão.
// O conteúdo nunca vai dar overflow, encolhe via FittedBox.scaleDown.
ResponsiveBox(
  layoutMode: ResponsiveLayoutMode.row,
  wrap: false,
  children: [
    Icon(Icons.home, size: 32),
    Text('Texto que pode ser longo', style: TextStyle(fontSize: 18)),
    ElevatedButton(onPressed: () {}, child: Text('Acao')),
  ],
)
```

### scaleToFit — preenche o espaço exato

```dart
// O conteúdo cresce OU encolhe para preencher o espaço do pai.
// Útil para banners, heroes e elementos que devem sempre ocupar 100% do espaço.
ResponsiveBox(
  scaleToFit: true,
  fullWidth: true,
  height: 400,
  child: BannerContent(),
)
```

### scaleUp — cresce mas não encolhe além do natural

```dart
// FittedBox.contain: cresce para preencher, mas mantém aspect ratio.
// Não encolhe abaixo do tamanho natural.
ResponsiveBox(
  shrinkOnOverflow: true,
  scaleUp: true,
  child: LogoWidget(),
)
```

### Dimensões em porcentagem de viewport

```dart
// Card que ocupa sempre 80% da largura e 50% da altura da tela.
ResponsiveBox(
  widthPercent: 0.8,
  heightPercent: 0.5,
  backgroundColor: Colors.white,
  padding: const EdgeInsets.all(24),
  child: Content(),
)
```

### Largura máxima com centralização

```dart
// Conteúdo centralizado, nunca ultrapassa 900px de largura.
// Útil para seções de página web com área de leitura limitada.
ResponsiveBox(
  maxWidth: 900,
  fullWidth: true,
  alignment: Alignment.center,
  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
  children: [
    Titulo(),
    Descricao(),
    BotaoCTA(),
  ],
)
```

### Stack responsivo

```dart
// Elementos sobrepostos com alinhamento centralizado.
ResponsiveBox(
  layoutMode: ResponsiveLayoutMode.stack,
  align: SmartAlign.center,
  width: 300,
  height: 300,
  children: [
    BackgroundImage(),
    Positioned(bottom: 16, child: Caption()),
  ],
)
```

### mainAxisAlignment para espaçamento entre itens

```dart
// spaceBetween sem usar Expanded — compatível com shrinkOnOverflow.
ResponsiveBox(
  layoutMode: ResponsiveLayoutMode.row,
  wrap: false,
  fullWidth: true,
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Logo(),
    NavMenu(),
    UserAvatar(),
  ],
)
```

### Decoração personalizada

```dart
ResponsiveBox(
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.purple, Colors.blue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
  ),
  child: HeroContent(),
)
```

---

## UniversalResponsiveLayout

Exibe um widget diferente dependendo do breakpoint atual.

```dart
UniversalResponsiveLayout(
  mobileBuilder: (context) => MobileNavBar(),
  tabletBuilder: (context) => TabletSidebar(),
  desktopBuilder: (context) => DesktopNavRail(),
)
```

**Regras de fallback:**
- Se `desktopBuilder` for `null` em desktop → usa `tabletBuilder`
- Se `tabletBuilder` for `null` em tablet → usa `mobileBuilder`
- `mobileBuilder` é sempre obrigatório (fallback final)

---

## ResponsiveValue\<T\>

Encapsula qualquer valor com variante por breakpoint.

```dart
// Definição
final fontSize = ResponsiveValue<double>(mobile: 14, tablet: 16, desktop: 20);
final columns  = ResponsiveValue<int>(mobile: 1, tablet: 2, desktop: 4);
final padding  = ResponsiveValue<EdgeInsets>(
  mobile:  EdgeInsets.all(8),
  tablet:  EdgeInsets.all(16),
  desktop: EdgeInsets.all(32),
);

// Uso dentro de LayoutBuilder
LayoutBuilder(
  builder: (context, constraints) {
    return Text(
      'Ola',
      style: TextStyle(fontSize: fontSize.getValue(constraints)),
    );
  },
)
```

---

## UniversalResponsiveValueBuilder\<T\>

Wrapper widget para `ResponsiveValue` — elimina a necessidade de `LayoutBuilder` manual.

```dart
UniversalResponsiveValueBuilder<EdgeInsets>(
  value: ResponsiveValue(
    mobile:  EdgeInsets.all(8),
    tablet:  EdgeInsets.all(16),
    desktop: EdgeInsets.all(32),
  ),
  builder: (context, padding) {
    return Padding(
      padding: padding,
      child: Content(),
    );
  },
)
```

---

## ResponsiveGridLayout

Grid com número de colunas que muda automaticamente por breakpoint.

```dart
ResponsiveGridLayout(
  mobileCrossAxisCount: 1,   // < 600px: 1 coluna
  tabletCrossAxisCount: 2,   // >= 600px: 2 colunas
  desktopCrossAxisCount: 4,  // >= 1200px: 4 colunas
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  childAspectRatio: 1.5,     // largura / altura de cada célula
  children: produtos.map((p) => ProdutoCard(produto: p)).toList(),
)
```

**Parâmetros:**

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `mobileCrossAxisCount` | `int` | `1` | Colunas em mobile (< 600px) |
| `tabletCrossAxisCount` | `int` | `2` | Colunas em tablet (>= 600px) |
| `desktopCrossAxisCount` | `int` | `4` | Colunas em desktop (>= 1200px) |
| `crossAxisSpacing` | `double` | `8.0` | Espaçamento horizontal entre células |
| `mainAxisSpacing` | `double` | `8.0` | Espaçamento vertical entre células |
| `childAspectRatio` | `double` | `1.0` | Razão largura/altura de cada célula |
| `children` | `List<Widget>` | — | Itens do grid (obrigatório) |

> O `ResponsiveGridLayout` usa `shrinkWrap: true` e `NeverScrollableScrollPhysics` — deve ser colocado dentro de um `SingleChildScrollView` ou `ResponsiveBox(scrollable: true)` para rolar.

---

---

# Padrões de Composição

## Website completo

```dart
Scaffold(
  body: SingleChildScrollView(
    child: Column(
      children: [

        // Header fixo
        ResponsiveBox(
          layoutMode: ResponsiveLayoutMode.row,
          wrap: false,
          fullWidth: true,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          backgroundColor: Colors.white,
          children: [
            AutoElement(child: Logo()),
            UniversalResponsiveLayout(
              mobileBuilder: (_) => MenuHamburger(),
              desktopBuilder: (_) => NavLinks(),
            ),
          ],
        ),

        // Hero section
        AutoElement(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
          child: Column(
            children: [
              const Text('Titulo Hero', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold)),
              const Text('Subtitulo', style: TextStyle(fontSize: 24)),
              ElevatedButton(onPressed: () {}, child: const Text('Comecar')),
            ],
          ),
        ),

        // Grid de cards
        ResponsiveBox(
          padding: const EdgeInsets.all(32),
          child: ResponsiveGridLayout(
            mobileCrossAxisCount: 1,
            tabletCrossAxisCount: 2,
            desktopCrossAxisCount: 3,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.2,
            children: features.map((f) => AutoElement(child: FeatureCard(f))).toList(),
          ),
        ),

      ],
    ),
  ),
)
```

## Painel dividido (sidebar + conteúdo)

```dart
ResponsiveBox(
  layoutMode: ResponsiveLayoutMode.row,
  wrap: false,
  fullHeight: true,
  children: [
    // Sidebar fixa com largura de 25%
    ResponsiveBox(
      widthPercent: 0.25,
      fullHeight: true,
      backgroundColor: const Color(0xFF1E1E2E),
      child: AutoElement(child: SidebarContent()),
    ),

    // Conteúdo principal ocupa o restante
    ResponsiveBox(
      flex: 1,
      flexFit: FlexFit.tight,
      scrollable: true,
      padding: const EdgeInsets.all(32),
      child: AutoElement(child: MainContent()),
    ),
  ],
)
```

## Card com tamanho mínimo garantido

```dart
// O card nunca vai encolher abaixo de 200×150,
// mas também nunca vai dar overflow — encolhe com FittedBox.
ResponsiveBox(
  minWidth: 200,
  minHeight: 150,
  maxWidth: 400,
  shrinkOnOverflow: true,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
  ),
  child: AutoElement(child: CardContent()),
)
```

---

---

# Perguntas Frequentes

**Posso usar `AutoElement` dentro de `ResponsiveBox`?**
Sim — é o padrão recomendado. `ResponsiveBox` organiza o layout; `AutoElement` escala o conteúdo de cada bloco.

**Posso usar `AutoElement` sem `ResponsiveBox`?**
Sim. Para páginas simples com um único bloco de conteúdo, `AutoElement` sozinho já resolve.

**`AutoElement` e `Transform.scale` são equivalentes?**
Não. `Transform.scale` escala visualmente mas não avisa o layout — os outros widgets não abrem espaço para o conteúdo crescido, causando sobreposição. `AutoElement` usa `MediaQuery.textScaler` e `IconTheme`, que são mecanismos nativos do Flutter reconhecidos pelo sistema de layout.

**O que acontece se eu colocar um `Expanded` dentro de `ResponsiveBox`?**
O `ResponsiveBox` detecta automaticamente a presença de `Expanded`, `Flexible` ou `Spacer` e desativa o `wrap` automático e o `shrinkOnOverflow` (que são incompatíveis com widgets flexíveis). O layout fica estrito como um `Row`/`Column` nativo.

**`ResponsiveGridLayout` precisa estar dentro de um scroll?**
Sim. Ele usa `shrinkWrap: true` e `NeverScrollableScrollPhysics`. Coloque-o dentro de `SingleChildScrollView` ou `ResponsiveBox(scrollable: true)`.

**Como mudar o ponto de referência do `AutoElement`?**
Altere a constante `kReferenceWidth` em `auto_element.dart`:
```dart
const double kReferenceWidth = 1440.0; // se o design foi feito para 1440px
```

**`shrinkOnOverflow`, `scaleToFit` e `scaleUp` — qual usar?**

| Cenário | Configuração |
|---|---|
| Comportamento padrão seguro (sem overflow) | `shrinkOnOverflow: true` (padrão) |
| Conteúdo que preenche exatamente o espaço | `scaleToFit: true` |
| Conteúdo que pode crescer mas não encolhe | `shrinkOnOverflow: true, scaleUp: true` |
| Conteúdo com scroll quando não couber | `scrollable: true` |




## Ocultação Condicional (ResponsiveHide)

Oculta widgets inteiros de forma simples dependendo do tamanho da tela. Sem cálculos feios na árvore.

`dart
ResponsiveHide(
  mobile: true, // Oculta telas com menos de 600px
  child: Image.asset('banner_decorativo.png'),
)
`

| Parâmetro | Tipo | Descrição |
|---|---|---|
| mobile | ool | Se 	rue, some em telas com < 600px |
| 	ablet | ool | Se 	rue, some em telas de 600px até 1199px |
| desktop | ool | Se 	rue, some em telas >= 1200px |

---

## Animações Fluídas (animated)

Se você definir nimated: true no seu ResponsiveBox, qualquer mudança de layout, tamanho, alinhamento, preenchimento, cor de fundo ou margem será animada automaticamente de forma fluida usando transições nativas!
Isso é incrivelmente útil ao usar wrap: true, pois quando a tela diminui e os elementos quebram para a próxima linha, o componente pai vai crescer ou encolher suavemente (AnimatedSize) em vez de pular bruscamente!

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| nimated | ool | alse | Se 	rue, transita todas as mudanças visuais e de tamanho automaticamente. |
| nimationDuration | Duration | 300ms | A duração da animação (padrão é 300 milissegundos). |
