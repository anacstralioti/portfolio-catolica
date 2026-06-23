# Documentação Técnica — Ichigo: Memórias do Oceano

**Engine**: Godot 4.5 com **Linguagem**: GDScript;

---

## Índice

1. [Visão Geral da Arquitetura](#1-visão-geral-da-arquitetura)
2. [Padrões de Projeto Aplicados](#2-padrões-de-projeto-aplicados)
3. [Estrutura de Arquivos](#3-estrutura-de-arquivos)
4. [Documentação por Módulo](#4-documentação-por-módulo)
   - 4.1 [Núcleo — GameGlobal](#41-núcleo--gameglobal)
   - 4.2 [Gerenciador de Jogo — GameManager (FSM)](#42-gerenciador-de-jogo--gamemanager-fsm)
   - 4.3 [Jogador — Player](#43-jogador--player)
   - 4.4 [Interface — HUD](#44-interface--hud)
   - 4.5 [Menu Principal — TitleScreen](#45-menu-principal--titlescreen)
   - 4.6 [Menu de Pausa — PauseMenu](#46-menu-de-pausa--pausemenu)
   - 4.7 [Narrativa — NarrativeUI](#47-narrativa--narrativeui)
   - 4.8 [Overlays de Memória](#48-overlays-de-memória)
   - 4.9 [Objetos do Mundo](#49-objetos-do-mundo)
   - 4.10 [Áudio Procedural — ProceduralSFX](#410-áudio-procedural--proceduralsfx)
   - 4.11 [Cutscene do Tsunami](#411-cutscene-do-tsunami)
   - 4.12 [Transição de Fase — PhaseIntro](#412-transição-de-fase--phaseintro)
5. [Sistema de Save/Load](#5-sistema-de-saveload)
6. [Sistema de Controles](#6-sistema-de-controles)

---

## 1. Visão Geral da Arquitetura

O jogo segue uma arquitetura em camadas, onde cada camada tem responsabilidade bem delimitada:

```
┌────────────────────────────────────────────────────────────┐
│                      APRESENTAÇÃO                          │
│  TitleScreen · PauseMenu · HUD · NarrativeUI · Overlays   │
├────────────────────────────────────────────────────────────┤
│                        DOMÍNIO                             │
│  GameManager (FSM) · Player · Inventory · Checkpoint       │
├────────────────────────────────────────────────────────────┤
│                    MUNDO / ENTIDADES                        │
│  Collectible · Crab · Seagull · Kite · SandHole            │
│  SandCastle · MusicBox · MemoryObject · Puddle             │
├────────────────────────────────────────────────────────────┤
│                  INFRAESTRUTURA / DADOS                    │
│  GameGlobal (Autoload) · Save JSON (user://)               │
└────────────────────────────────────────────────────────────┘
```

### Fluxo de Cenas

```
title_screen.tscn
    ├── [Novo Jogo] ──► phase_intro.tscn ──► fase1_ecos_silencio.tscn
    └── [Continuar] ──────────────────────► fase1_ecos_silencio.tscn
                                                │
                                          [progress >= 1.0]
                                                │
                                         tsunami_cutscene.tscn
                                                │
                                         phase_intro.tscn (Fase 2)
                                                │
                                         fase2_ruinas_oceano.tscn (placeholder)
```

---

## 2. Padrões de Projeto Aplicados

### 2.1 Finite State Machine (FSM) — Padrão State

Implementado em `game_manager.gd`. O ambiente inteiro reage ao estado atual:

```
INICIO (0–15%) → RECONHECIMENTO (15–40%) → LEMBRANCA (40–65%)
                                                ↓
                         RESOLUCAO (85–100%) ← CONFRONTO (65–85%)
```

Cada transição dispara: mudança climática, nova fala narrativa e ajuste visual de detritos.

### 2.2 Observer / Signal — Padrão Publicador-Assinante

Godot usa sinais como sistema nativo de eventos. O projeto os emprega para desacoplar completamente os módulos:

| Sinal | Emissor | Receptor(es) |
|---|---|---|
| `shell_collected(total)` | `player.gd` | `game_manager.gd` |
| `item_picked_up(name)` | `player.gd` | `game_manager.gd` |
| `interact_pressed` | `player.gd` | `sand_hole.gd` |
| `state_changed(s)` | `game_manager.gd` | (disponível para HUD/UI) |
| `phase_complete` | `game_manager.gd` | `game_manager._on_phase_complete()` |
| `inventory_changed` | `inventory.gd` | (disponível para HUD) |

### 2.3 Singleton / Autoload — Padrão Singleton

`game_global.gd` é registrado como Autoload no Godot, tornando-o acessível globalmente sem referências diretas. Armazena apenas dados que precisam persistir entre cenas:

```gdscript
# game_global.gd
var next_phase_number  := 1
var next_phase_name    := "Ecos do Silêncio"
var current_save_slot  := 1
var photo_texture: Texture2D = null  # textura da foto coletada (para reabrir pelo inventário)
var photo_caption: String    = ""    # legenda da foto
var has_diary: bool          = false # flag para reabrir a carta pelo inventário
```

### 2.4 Template Method / Herança de Cena

Todos os objetos de memória interativos (`sand_castle.gd`, `music_box.gd`, `memory_object.gd`, `kite.gd`) seguem o mesmo ciclo de vida:

1. `_ready()` → inicializa, registra no grupo, esconde prompt
2. `_process()` → detecta proximidade, mostra prompt
3. `_use()` / `_collect()` → dispara narrativa e/ou flashback

`memory_object.gd` é o caso mais genérico, configurável por `@export`. Os demais specializam comportamentos específicos.

### 2.5 Command — `interact_pressed`

O sinal `interact_pressed` em `player.gd` funciona como Command: o jogador emite a intenção de interagir, e os objetos próximos (como `sand_hole.gd`) conectam/desconectam dinamicamente esse sinal conforme a proximidade, evitando polling constante.

### 2.6 Strategy — Overlays Intercambiáveis

Três overlays distintos (`photo_overlay`, `flashback_overlay`, `diary_overlay`) são carregados dinamicamente e injetados na árvore de cenas conforme o tipo de objeto coletado. `memory_object.gd` decide qual overlay usar via flags de exportação (`use_photo_overlay`, `use_diary_overlay`, `has_flashback`).

---

## 3. Estrutura de Arquivos

```
ichigo/
├── scenes/
│   ├── title_screen.tscn         # Menu principal com slots de save
│   ├── phase_intro.tscn          # Tela de transição entre fases
│   ├── fase1_ecos_silencio.tscn  # Fase 1 completa (mapa + GameManager)
│   ├── fase2_ruinas_oceano.tscn  # Fase 2 (placeholder)
│   ├── tsunami_cutscene.tscn     # Cutscene animada (pixel art procedural)
│   ├── pause_menu.tscn           # Overlay de pausa (CanvasLayer 30)
│   ├── photo_overlay.tscn        # Overlay para fotos de memória
│   ├── diary_overlay.tscn        # Overlay estilo diário rasgado
│   └── flashback_overlay.tscn    # Tela branca com legenda emocional
│
├── scripts/
│   ├── game_global.gd            # Autoload: dados entre cenas
│   ├── game_manager.gd           # FSM narrativa + save/load + clima
│   ├── player.gd                 # Controlador de Ichigo
│   ├── hud.gd                    # Interface do jogador (inventário + progresso)
│   ├── inventory.gd              # Lógica de inventário (sinais)
│   ├── narrative_ui.gd           # Exibição de textos com typewriter
│   ├── title_screen.gd           # Menu principal + gestão de slots
│   ├── pause_menu.gd             # Menu de pausa com confirmação
│   ├── photo_overlay.gd          # Overlay fotográfico responsivo
│   ├── diary_overlay.gd          # Overlay de diário com manchas de tinta
│   ├── flashback.gd              # Overlay de flashback simples
│   ├── memory_object.gd          # Objeto de memória genérico (exportável)
│   ├── checkpoint.gd             # Ponto de salvamento automático
│   ├── collectible.gd            # Item coletável com bobbing e efeitos
│   ├── crab.gd                   # NPC caranguejo (patrulha FSM)
│   ├── seagull.gd                # NPC gaivota (detecta proximidade e foge)
│   ├── kite.gd                   # Pipa rasgada (dispara narrativa)
│   ├── debris.gd                 # Destroços físicos (RigidBody2D)
│   ├── sand_castle.gd            # Castelo de areia (requer balde)
│   ├── sand_hole.gd              # Buraco de areia (requer pá)
│   ├── music_box.gd              # Caixinha de música (flashback)
│   ├── puddle.gd                 # Poça d'água (reduz velocidade)
│   ├── footprints.gd             # Pegadas (efeito visual de impermanência)
│   ├── parallax_bg.gd            # Parallax do mar em loop
│   ├── phase_intro.gd            # Tela de introdução de fase
│   ├── tsunami_cutscene.gd       # Cutscene completa em pixel art procedural
│   └── fase2_placeholder.gd      # Placeholder Fase 2
│
├── sprites/                      # Assets visuais (SVG/PNG)
├── tests/                        # Testes automatizados (GUT)
│   ├── test_procedural_sfx.gd    # 20 testes de geração de áudio
│   ├── test_game_global.gd       # 15 testes do singleton GameGlobal
│   ├── test_fsm_logica.gd        # 18 testes da lógica FSM
│   ├── test_inventario.gd        # 17 testes do sistema de inventário
│   └── test_coletaveis.gd        # 15 testes de coletáveis e objetos
├── README.md                     # Documentação acadêmica do projeto
├── GDD.md                        # Game Design Document
├── RFC.md                        # Requisitos e especificação técnica
├── .gutconfig.json               # Configuração do GUT (aponta para tests/)
└── Documentação Técnica.md       # Este arquivo
```

---

## 4. Documentação por Módulo

### 4.1 Núcleo — GameGlobal

**Arquivo**: [scripts/game_global.gd](scripts/game_global.gd)  
**Tipo**: Autoload (Singleton global)

Responsável por carregar dados que precisam sobreviver à troca de cenas, já que o Godot destrói e recria a árvore de nós a cada `change_scene_to_file()`.

```gdscript
var next_phase_number  := 1      # Qual fase carregar em phase_intro
var next_phase_name    := "Ecos do Silêncio"  # Nome exibido na intro
var current_save_slot  := 1      # Slot escolhido no menu (1–3)
```

**Por que Autoload?** Porque é o único mecanismo do Godot que persiste entre cenas sem precisar de referências cruzadas. Mantém apenas o mínimo necessário — dados de navegação e slot ativo.

---

### 4.2 Gerenciador de Jogo — GameManager (FSM)

**Arquivo**: [scripts/game_manager.gd](scripts/game_manager.gd)  
**Cena pai**: `fase1_ecos_silencio.tscn`  
**Grupo Godot**: `"game_manager"`

É o coração do jogo. Centraliza a FSM narrativa, o sistema de clima, o spawn aleatório de entidades e o save/load.

#### FSM de Estados

```gdscript
enum State {
    INICIO,          # 0–15%   — praia quieta, sol claro
    RECONHECIMENTO,  # 15–40%  — memórias surgem, leve nublado
    LEMBRANCA,       # 40–65%  — lembranças fortes, céu encoberto
    CONFRONTO,       # 65–85%  — pico emocional, chuva leve
    RESOLUCAO        # 85–100% — caminhada final, luz dourada
}
```

A transição de estado ocorre em `_process()`, comparando `progress` (posição X do jogador normalizada de 0 a 1 sobre o mapa de 6400px):

```gdscript
func _process(_d: float) -> void:
    match state:
        State.INICIO:
            if progress >= 0.15: _enter(State.RECONHECIMENTO)
        # ...
```

#### Sistema de Clima Procedural

Cada estado aplica uma cor de tint e ativa/desativa a chuva por `CPUParticles2D`:

| Estado | Tint | Chuva |
|---|---|---|
| INICIO | amarelo suave (0.0 alpha) | desligada |
| RECONHECIMENTO | azul pálido (0.06 alpha) | — |
| LEMBRANCA | azul acinzentado (0.18 alpha) | — |
| CONFRONTO | cinza-azulado (0.30 alpha) | **ligada** |
| RESOLUCAO | dourado (0.14 alpha) | desligada |

O `CanvasLayer` de clima (`layer = 8`) fica acima do mundo mas abaixo da UI.

#### Spawn Aleatório Determinístico

O método `_randomize_world()` usa um `RandomNumberGenerator` com seed salva em JSON. Isso garante que ao continuar um save, os objetos do mundo apareçam nas mesmas posições da sessão anterior:

```gdscript
func _randomize_world() -> void:
    _rng.seed = _run_seed   # seed carregada do save, ou nova aleatória
    _randomize_group_positions("crab",        CRAB_ZONES)
    _randomize_group_positions("puddle",      PUDDLE_ZONES)
    _randomize_group_positions("sandhole",    HOLE_ZONES)
    _randomize_group_positions("memory_item", MEMORY_ZONES)
```

Zonas definidas como pares `[x_min, x_max]` garantem que objetos não apareçam sobrepostos a checkpoints (raio de 90px de clearance).

#### Dicionário de Narrativas

As falas são centralizadas em um `const NARRATIVAS: Dictionary`, garantindo que a narrativa seja um dado, não lógica:

```gdscript
const NARRATIVAS := {
    "intro"       : "Está tudo tão quieto...",
    "confronto"   : "Não consigo parar de pensar nela.",
    "item_shovel" : "A pá dela. Ainda estava aqui.",
    # ...
}
```

---

### 4.3 Jogador — Player

**Arquivo**: [scripts/player.gd](scripts/player.gd)  
**Tipo**: `CharacterBody2D`  
**Grupo Godot**: `"player"`

#### Física e Movimentação

- **Gravidade**: 980 px/s²
- **Velocidade caminhada**: 90 px/s
- **Velocidade corrida**: 160 px/s (tecla `run`)
- **Pulo**: −320 px/s (eixo Y)
- **Poça d'água**: multiplica velocidade por 0.45 via `enter_puddle()` / `exit_puddle()`
- **Estado `_disabled`**: após o fim da fase, o jogador é desativado e caminha automaticamente para a direita (cinemática de saída)

#### Sistema de Colisão

```gdscript
collision_layer = 1   # o jogador está na camada 1
collision_mask  = 1   # colide com geometria estática (layer 1)
                      # NÃO colide com caranguejos (layer 2) — intencional
```

#### Animações

O método `_update_anim()` seleciona a animação baseado em prioridades:
1. No ar: `jump` ou `fall`
2. Agachado: `crouch`
3. Segurando item: `hold`
4. Movendo: `run` ou `walk`
5. Parado: `idle`

O sprite "item na mão" (`HeldItemSprite`) é espelhado automaticamente junto com o personagem.

#### Câmera Dinâmica

```gdscript
func _attach_camera() -> void:
    var cam := get_viewport().get_camera_2d()
    if cam: cam.reparent(self, false)
```

A câmera definida na cena é reparentada ao jogador no `_ready()`, tornando-a filha do personagem sem alterar sua posição mundial.

#### Sinais Emitidos

| Sinal | Quando |
|---|---|
| `shell_collected(total)` | Ao coletar uma concha |
| `item_picked_up(name)` | Ao coletar pá, balde, foto etc. |
| `interact_pressed` | A cada pressão da tecla `interact` (E/Z) |

---

### 4.4 Interface — HUD

**Arquivo**: [scripts/hud.gd](scripts/hud.gd)  
**Tipo**: `Control`  
**Grupo Godot**: `"hud"`

#### Barra de Inventário

Construída inteiramente por código em `_build_inv_bar()` — sem dependência de nós no TSCN. Isso a torna independente da estrutura da cena pai e facilita testes.

- 8 slots gerados dinamicamente
- Cada slot: `Panel` + `TextureRect` (ícone) + `Label` (quantidade) + `Label` (número 1–8)
- Teclas 1–8 selecionam o slot ativo
- Slot ativo: borda dourada (`Color(0.95, 0.85, 0.25)`) com 2px de largura
- Hint acima da barra: `"selecione 1-8 para equipar item"` em amarelo suave (`Color(1.0, 0.92, 0.62, 0.78)`, font_size 7)
- Foto e carta coletadas podem ser reabertas a qualquer momento: selecionar o slot correspondente e pressionar E reabre o overlay

#### Barra de Progresso

Atualiza via `create_tween()` com transição suave de 0.4s, chamada pelo `GameManager` a cada frame via `update_progress(v)`.

#### Serialização do Inventário

```gdscript
func get_inventory_data() -> Dictionary:
    return {
        "inventory": _inventory.duplicate(),
        "order":     _inv_order.duplicate(),
        "active":    _active_slot
    }

func restore_inventory(data: Dictionary) -> void:
    # reconstrói inventário a partir do dicionário do save
```

Isso permite que o `GameManager` salve e restaure o estado completo do inventário no JSON.

---

### 4.5 Menu Principal — TitleScreen

**Arquivo**: [scripts/title_screen.gd](scripts/title_screen.gd)  
**Tipo**: `Control`

#### Título Animado

O título "ICHIGO" (font_size 16, dourado) e subtítulo "Memórias do Oceano" (font_size 8) ficam posicionados no topo da tela. O título tem shimmer em loop via `Tween`:

```gdscript
var tw_sh := create_tween().set_loops()
tw_sh.tween_property(_title_lbl, "self_modulate", Color(1, 0.82, 0.45, 1), 2.2).set_trans(Tween.TRANS_SINE)
tw_sh.tween_property(_title_lbl, "self_modulate", Color(1, 0.97, 0.80, 1), 2.2).set_trans(Tween.TRANS_SINE)
```

O menu fica à direita da tela (painel semi-transparente), deixando o personagem visível no lado esquerdo.

#### Máquina de Estados do Menu

O menu usa flags booleanas para controlar estados mutuamente exclusivos:

```
Estado inicial
    ├── _credits_open = true  →  painel de créditos visível
    ├── _in_slot_panel = true →  painel de slots visível
    │       ├── _slot_mode = "new"       (Novo Jogo)
    │       └── _slot_mode = "continue"  (Continuar)
    └── (nenhum)              →  menu principal
```

#### Gestão de Slots de Save

Ao abrir, verifica quais slots têm arquivo via `FileAccess.file_exists()`:

```gdscript
for i in MAX_SLOTS:
    _slot_has_save[i] = FileAccess.file_exists(SAVE_PATH_TPL % (i + 1))
```

**Modo Novo Jogo**: slots com save ficam invisíveis e o cursor pula sobre eles.  
**Modo Continuar**: slots vazios ficam acinzentados (alpha 0.35) e não são selecionáveis.

Exibe progresso e checkpoints lidos diretamente do JSON:
```
Slot 1 — 42%  CP:2
```

#### Navegação Trimodal

O `_input()` lida com três formas de navegação sem conflito:
1. **Teclado**: Setas / W·S
2. **Teclado alternativo**: `_is_nav(event, KEY_W)` verifica manualmente para evitar conflito com `ui_up`
3. **Mouse**: `get_global_rect().has_point(pos)` no espaço de viewport 320×180

---

### 4.6 Menu de Pausa — PauseMenu

**Arquivo**: [scripts/pause_menu.gd](scripts/pause_menu.gd)  
**Arquivo de cena**: [scenes/pause_menu.tscn](scenes/pause_menu.tscn)  
**Tipo**: `CanvasLayer` (layer = 30, `PROCESS_MODE_ALWAYS`)

Instanciado diretamente na cena `fase1_ecos_silencio.tscn`, o menu de pausa sobrepõe tudo (layer 30 > qualquer outro elemento) e continua processando mesmo com `get_tree().paused = true`.

#### Máquina de Estados Interna

```gdscript
enum Mode { MAIN, CONFIRM }
```

| Estado | Opções disponíveis |
|---|---|
| `MAIN` | Continuar · Voltar ao Menu · Sair |
| `CONFIRM` | Sim, continuar · Não, voltar |

#### Lógica de Segurança

- O painel de confirmação aparece para **Voltar ao Menu** e **Sair**
- O padrão de seleção é `_confirm_sel = 1` (índice de "Não, voltar") — o jogador precisa mover ativamente para "Sim" antes de confirmar
- A ação **não salva** o progresso atual; o jogador retorna ao último checkpoint

#### Proteção contra Abertura Indevida

```gdscript
func _try_open() -> void:
    var root := get_tree().root
    for oname in ["PhotoOverlay", "DiaryOverlay", "FlashbackOverlay"]:
        if root.get_node_or_null(oname): return  # bloqueia se overlay aberto
    # ...
```

---

### 4.7 Narrativa — NarrativeUI

**Arquivo**: [scripts/narrative_ui.gd](scripts/narrative_ui.gd)  
**Tipo**: `Control`

Exibe falas narrativas com efeito de máquina de escrever (typewriter) via `visible_ratio`.

#### Fila de Mensagens

```gdscript
var _queue: Array[String] = []

func show_text(text: String, dur: float = 2.0, interrupt: bool = false) -> void:
    if _busy and not interrupt:
        _queue.append(text)  # enfileira se ocupado
        return
    _display(text, dur)
```

Quando uma mensagem termina, `_done()` verifica a fila e exibe a próxima automaticamente, garantindo que nenhuma fala seja perdida.

#### Sequência de Animação (Tween)

```
fade-in (0.1s) → typewriter (comprimento × 0.018s/char) → espera (dur) → fade-out (0.4s)
```

---

### 4.8 Overlays de Memória

Três overlays distintos lidam com diferentes tipos de memória narrativa. Todos são `CanvasLayer`, carregados dinamicamente e removidos da árvore ao fechar.

#### PhotoOverlay

**Arquivo**: [scripts/photo_overlay.gd](scripts/photo_overlay.gd)

Exibe uma foto com moldura polaroid responsiva ao tamanho do viewport. O layout é calculado em `_layout()` em proporções (não pixels fixos), garantindo que funcione em qualquer resolução:

```gdscript
var frame_w := vp.x * 0.62     # 62% da largura do viewport
var photo_h := vp.y * 0.56     # 56% da altura
```

Fotos podem ser **re-examinadas**: o objeto de memória não é destruído, apenas fica semi-transparente (alpha 0.5).

#### DiaryOverlay

**Arquivo**: [scripts/diary_overlay.gd](scripts/diary_overlay.gd)

Simula uma página de diário com manchas de água (`WaterStainA`, `WaterStainB`) e linhas de tinta apagadas (`InkSmear*`) que representam texto ilegível. O posicionamento de todos os elementos é calculado dinamicamente em `_layout()` e `_place_smears()`.

#### FlashbackOverlay

**Arquivo**: [scripts/flashback.gd](scripts/flashback.gd)

O overlay mais simples: tela branca com legenda. Usado para memórias vívidas:
```
fade-in (0.7s) → espera (4.0s) → fade-out (1.2s) → queue_free()
```

---

### 4.9 Objetos do Mundo

#### Collectible — Item Coletável

**Arquivo**: [scripts/collectible.gd](scripts/collectible.gd)

- Animação de "bobbing" (flutuar para cima e para baixo) via `sin(_t * bob_speed)`
- Brilho pulsante no `Glow` sprite via `sin(_t * 4.0)`
- Ao ser coletado: escala para 1.6×, desaparece, partículas explodem, `queue_free()`

#### Crab — Caranguejo

**Arquivo**: [scripts/crab.gd](scripts/crab.gd)

NPC com FSM própria de três estados:
```
RIGHT → (distância > patrol_dist) → PAUSE → LEFT → (distância > patrol_dist) → PAUSE → ...
```

Camada de colisão separada do jogador (`layer=2, mask=1`) — o caranguejo anda no chão sem bloquear Ichigo.

#### Seagull — Gaivota

**Arquivo**: [scripts/seagull.gd](scripts/seagull.gd)

Fica em bobbing ocioso até o jogador entrar em `NOTICE_DIST = 72px`. Então voa na direção oposta ao jogador com um leve ângulo para cima. Quando sair da tela (`y < -80` ou `x < -100` ou `x > 6600`), chama `queue_free()`.

#### SandHole — Buraco de Areia

**Arquivo**: [scripts/sand_hole.gd](scripts/sand_hole.gd)

Usa o sinal `interact_pressed` do jogador via conexão dinâmica (conecta quando próximo, desconecta quando longe), evitando que a interação dispare para objetos distantes. Requer a pá equipada para preencher:

```gdscript
if close:
    if not _connected:
        _connected = true
        _player.interact_pressed.connect(_try_fill)
else:
    if _connected:
        _connected = false
        _player.interact_pressed.disconnect(_try_fill)
```

#### SandCastle — Castelo de Areia

**Arquivo**: [scripts/sand_castle.gd](scripts/sand_castle.gd)

Requer o balde selecionado no slot ativo (não apenas coletado). O prompt muda conforme o estado do jogador:
- `active == "bucket"` → "Encher o fosso"
- `has_bucket` mas não equipado → "Equipe o balde!"
- Sem balde → "Falta água..."

#### MusicBox — Caixinha de Música

**Arquivo**: [scripts/music_box.gd](scripts/music_box.gd)

Ao interagir, toca a melodia procedural `ProceduralSFX.music_box_melody()` (7 notas em Lá menor com timbre de sino) e agenda um flashback com delay calculado pelo comprimento do texto:

```gdscript
var wait := narrative_text.length() * 0.045 + 4.5
```

Assim o flashback sempre aparece após a fala terminar de ser lida.

#### MemoryObject — Objeto de Memória Genérico

**Arquivo**: [scripts/memory_object.gd](scripts/memory_object.gd)

O objeto mais configurável do projeto. Controla via `@export`:

| Propriedade | Tipo | Efeito |
|---|---|---|
| `item_type` | String | Que item adiciona ao inventário |
| `narrative_text` | String | Fala exibida ao coletar |
| `has_flashback` | bool | Abre `flashback_overlay` |
| `flashback_caption` | String | Texto do flashback |
| `use_photo_overlay` | bool | Abre `photo_overlay` (re-examinável) |
| `overlay_texture` | Texture2D | Imagem da foto |
| `use_diary_overlay` | bool | Abre `diary_overlay` |

#### Puddle, Footprints, Kite, Debris

- **Puddle**: Area2D com lambdas inline — `body.enter_puddle()` / `body.exit_puddle()`
- **Footprints**: tween em loop de alpha 0.20 ↔ 0.80 (pulsa lentamente, sugere impermanência)
- **Kite**: balança em `tween_loops()` com `TRANS_SINE`; emite narrativa uma única vez quando o jogador chega perto
- **Debris**: `RigidBody2D` com `linear_damp = 3.5` e velocidade clamped a ±110 px/s para parecer destroço pesado

#### ParallaxBg

**Arquivo**: [scripts/parallax_bg.gd](scripts/parallax_bg.gd)

Desloca o `SeaLayer` na horizontal via `motion_offset.x`, fazendo o mar parecer se mover:

```gdscript
_scroll = fmod(_scroll + SEA_SPEED * delta, 640.0)
sea_layer.motion_offset.x = _scroll
```

O `fmod` garante que o scroll nunca extrapole (loop perfeito).

---

### 4.10 Áudio Procedural — ProceduralSFX

**Arquivo**: [scripts/procedural_sfx.gd](scripts/procedural_sfx.gd)  
**Tipo**: Classe estática (`class_name ProceduralSFX`)

Todo o áudio do jogo é gerado em tempo real via `AudioStreamWAV` (taxa 22050 Hz, mono, 16 bits) — sem nenhum arquivo de áudio externo no repositório.

#### Sons disponíveis

| Método | Duração | Uso |
|---|---|---|
| `footstep_sand()` | 85ms | Passo de Ichigo na areia (4 variações, seed aleatória) |
| `item_pickup()` | 180ms | Coleta de item (chirp 380→760 Hz) |
| `checkpoint_ping()` | 380ms | Ativação de checkpoint (Dó5→Mi5) |
| `sand_fill()` | 240ms | Tampar buraco com pá (whoosh + thud) |
| `music_box_melody()` | ~3.5s | Melodia 7 notas Lá menor (timbre de sino) |
| `thunder()` | 2s | Trovão (estalo HP + rumble LP, pitch aleatório) |
| `storm_loop()` | 3s loop | Chuva + vento (seed 7391, LOOP_FORWARD) |
| `ocean_loop()` | 4s loop | Ondas do mar (seed 1337, LOOP_FORWARD) |

#### Loops com seed fixa

`storm_loop()` e `ocean_loop()` usam `rng.seed` fixo para garantir que o loop seja matematicamente idêntico a cada geração — condição necessária para que `LOOP_FORWARD` funcione sem clique audível na emenda.

#### Música ambiente

O `GameManager` gera um drone em Lá menor em tempo real via `AudioStreamGenerator` (não `AudioStreamWAV`). A cada frame, `_fill_ambience()` empurra amostras calculadas por senos sobrepostos:

```gdscript
s += sin(TAU * 82.4  * _amb_t) * 0.10  # Mi2 — baixo profundo
s += sin(TAU * 110.0 * _amb_t) * 0.07  # Lá2 — nota base
s += sin(TAU * 164.8 * _amb_t) * 0.05  # Mi3 — quinta justa
s += sin(TAU * 220.0 * _amb_t) * 0.03 * shimmer  # Lá3 — shimmer via LFO 0.07 Hz
```

As ondas do mar tocam em camada separada via `ocean_loop()` com volume `−12 dB`, presente durante toda a Fase 1.

---

### 4.11 Cutscene do Tsunami

**Arquivo**: [scripts/tsunami_cutscene.gd](scripts/tsunami_cutscene.gd)

A cutscene é renderizada inteiramente por código usando a API `_draw()` do Godot — sem sprites externos. Cada frame redesenha a cena completa com `queue_redraw()`.

#### Paleta de Cores (definida como constantes)

```gdscript
const C_OCEAN    := Color(0.04, 0.18, 0.36)  # oceano profundo
const C_WAVE_C   := Color(0.12, 0.58, 0.82)  # face da onda — azul-ciano
const C_WAVE_D   := Color(0.24, 0.80, 0.94)  # frente brilhante
const C_SAND_M   := Color(0.72, 0.58, 0.30)  # areia média
```

#### Sequência de Animação (Tween)

```
Onda avança (4.5s) → impacto + vibração de câmera → inundação sobe (2.5s) → fade para preto → troca de cena
```

#### Elementos Desenhados

- **Céu**: 4 retângulos empilhados + blocos de nuvens + relâmpago procedural (pisca aleatoriamente)
- **Oceano**: retângulo base + 5 reflexos animados em `fmod(time * speed, W)`
- **Praia**: retângulos de areia com textura de variação via `(ix * 7 + iy * 3) % 17`
- **Palmeira**: 16 segmentos de tronco com inclinação + 7 frondes calculadas geometricamente
- **Placa com fogo**: chamas com `sin(time * 11.0)` para flicker e faíscas aleatórias
- **Onda do tsunami**: camadas de cor sobrepostas (sombra → corpo → face → crista → espuma)
- **Chuva**: 44 partículas com posição em `fmod(time * speed, tamanho_tela)`

---

### 4.12 Transição de Fase — PhaseIntro

**Arquivo**: [scripts/phase_intro.gd](scripts/phase_intro.gd)

Lê os dados de `GameGlobal` e exibe "Capítulo N — Nome da Fase" com fade-in e fade-out:

```
fade-in (1.5s) → espera (3.0s) → fade-out (1.5s) → troca de cena
```

A cena destino é determinada por `GameGlobal.next_phase_number` em um `match`.

---

## 5. Sistema de Save/Load

### Formato do Arquivo JSON

Salvo em `user://fase1_save_slot{N}.json` (onde N é 1, 2 ou 3):

```json
{
  "shells":      3,
  "checkpoints": 2,
  "progress":    0.47,
  "state":       2,
  "spawn_x":     2200.0,
  "run_seed":    1847392847,
  "inventory": {
    "inventory": { "shell": 3, "shovel": 1 },
    "order":     ["shell", "shovel"],
    "active":    1
  }
}
```

### Fluxo de Save

```
Evento disparador
    ↓
GameManager._save()
    ├── coleta dados: shells, checkpoints, progress, state, spawn_x, run_seed
    ├── pede inventário: hud.get_inventory_data()
    └── escreve: FileAccess.open(path, WRITE) → JSON.stringify()
```

**Quando salva automaticamente**:
- Ao atingir um checkpoint
- Ao coletar um item (pá, balde, foto)
- Ao completar a fase

**Quando NÃO salva** (intencional):
- Ao fechar/sair pelo menu de pausa — o jogador retorna ao último checkpoint

### Fluxo de Load

```
GameManager._load()
    ├── verifica existência do arquivo
    ├── parseia JSON
    ├── restaura: shells, checkpoints, progress, spawn_x, run_seed
    └── restaura inventário: hud.restore_inventory(data["inventory"])
```

O `spawn_x` define onde o jogador aparece no mapa, determinado pelo checkpoint mais recente.

### Checkpoints e Posições de Spawn

```gdscript
const _CHECKPOINT_X := { 0: 80.0, 1: 700.0, 2: 2200.0, 3: 4500.0 }
```

| ID | Posição X | Contexto narrativo |
|---|---|---|
| 0 | 80px | Início da praia |
| 1 | 700px | Após primeira zona de memórias |
| 2 | 2200px | Ponto médio do mapa |
| 3 | 4500px | Próximo ao fim da fase |

---

## 6. Sistema de Controles

### Mapa de Ações (Input Map)

| Ação | Teclas padrão | Contexto |
|---|---|---|
| `move_left` | ← , A | Mover Ichigo |
| `move_right` | → , D | Mover Ichigo |
| `move_down` | ↓ , S | Agachar |
| `jump` | Espaço | Pular |
| `run` | Shift | Correr (mantido) |
| `interact` | E , Z | Interagir com objetos |
| `ui_up` | ↑ | Navegar menus |
| `ui_down` | ↓ | Navegar menus |
| `ui_accept` | Enter | Confirmar |
| `ui_cancel` | ESC | Cancelar / Pausar |

### Navegação por Mouse nos Menus

Todos os menus (`title_screen.gd`, `pause_menu.gd`) implementam:
- `InputEventMouseMotion` → hover (destaca opção sob o cursor)
- `InputEventMouseButton LEFT` → clique (seleciona e confirma)

A detecção usa `Label.get_global_rect().has_point(pos)`. As Labels têm `mouse_filter = 2` (IGNORE), então os eventos chegam até o `_input()` da cena e são tratados manualmente. O espaço de coordenadas é 0–320 × 0–180 (viewport canvas_items), igual ao espaço de `get_global_rect()`.

### W/S como Alternativa nas Setas

```gdscript
func _is_nav(event: InputEvent, keycode: int) -> bool:
    return event is InputEventKey and event.pressed and not event.echo and event.keycode == keycode
```

Verifica `KEY_W` e `KEY_S` diretamente (fora do Input Map) porque essas teclas também são usadas para movimentação (`move_up`/`move_down`), e adicionar ao Input Map causaria conflitos.

---
