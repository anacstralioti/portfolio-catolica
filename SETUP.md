# 🍓 Ichigo: Memórias do Oceano — v2 Setup Guide

## Por que a cena anterior não abria?

O `.tscn` anterior usava `preload("res://...")` diretamente nos campos de propriedade,
o que é **inválido** no formato texto do Godot 4. A cena correta usa apenas:
- `[ext_resource]` para scripts (no topo do arquivo)
- `[sub_resource]` para shapes (CollisionShape2D, etc.)
- Referência `ExtResource("id")` e `SubResource("id")` nos nodes

---

## 📦 Estrutura do Projeto v2

```
ichigo_v2/
├── project.godot
├── background/
│   ├── beach_sunset.svg      ← Background completo (referência visual)
│   ├── sky_layer.svg         ← Camada céu (parallax 1)
│   ├── ocean_layer.svg       ← Camada mar (parallax 2)
│   └── sand_tile.svg         ← Tile 16x16
├── sprites/
│   └── ichigo/
│       ├── ichigo_idle.svg   ← Idle (chapéu morango + macacão azul)
│       ├── ichigo_run1.svg   ← Correndo frame 1
│       ├── ichigo_run2.svg   ← Correndo frame 2
│       ├── ichigo_jump.svg   ← Pulando (braços abertos, pernas dobradas)
│       └── ichigo_crouch.svg ← Agachando (olhos franzidos)
├── scripts/                  ← Todos corrigidos
├── scenes/
│   └── fase1_ecos_silencio.tscn  ← CORRIGIDA - abre no Godot 4.3+
└── audio/
```

---

## 🚀 Importar no Godot 4.3+

### Passo 1 — Copiar arquivos
Copie toda a pasta `ichigo_v2/` como pasta do projeto no Godot.

### Passo 2 — Importar SVGs como Texture2D
Para CADA svg em `sprites/` e `background/`:
1. Selecionar no FileSystem
2. aba **Import** → Type: **Texture2D**  
3. **SVG Scale: 4** (essencial para pixel art)
4. **Filter: Nearest** ← CRÍTICO
5. Clicar **Reimport**

### Passo 3 — Criar SpriteFrames da Ichigo
No node `AnimatedSprite2D` de Ichigo:

1. Inspector → **SpriteFrames** → New SpriteFrames
2. Criar animações:

| Animação | Frames | FPS | Loop |
|----------|--------|-----|------|
| `idle`   | ichigo_idle.svg | 4 | ✅ |
| `walk`   | run1, run2 (alternando) | 8 | ✅ |
| `run`    | run1, run2 | 12 | ✅ |
| `jump`   | ichigo_jump.svg | 4 | ❌ |
| `crouch` | ichigo_crouch.svg | 4 | ❌ |

**Para walk/idle:** adicione idle como frame 1 e 3, run1 como frame 2
para simular o balanço do corpo.

### Passo 4 — Vincular câmera ao player
Selecione `Camera2D`, no Inspector:
- **Process Callback:** Idle
Depois, no script do player, adicione em `_ready()`:
```gdscript
var cam = get_viewport().get_camera_2d()
if cam: cam.reparent(self, false)
```

Ou: arraste `Camera2D` para dentro do node `Ichigo` na hierarquia da cena.

### Passo 5 — Configurar TileMap do chão
1. Selecionar `SandTiles` (TileMapLayer)
2. TileSet → New TileSet → Add Source → `sand_tile.svg`
3. Tile size: **16×16**
4. Pintar o chão em y=0 por toda a largura
5. Adicionar colisão: selecionar tile → Collision tab → desenhar retângulo

### Passo 6 — Configurar Sprites dos nodes
Para cada obstáculo/item na cena (Shell1, Shell2... SandHole1, Crab1...):
- Selecionar o nó `Sprite2D` filho
- Arrastrar a textura SVG correspondente

### Passo 7 — Configurar ParallaxBackground
1. `SkyLayer/Sky` → textura: `sky_layer.svg`, position: (320, 55)
2. `SeaLayer/Sea` → textura: `ocean_layer.svg`, position: (320, 24)
3. Fundo da viewport: cor `#1f1a28` (roxo escuro do céu noturno)

---

## 🎮 Controles

| Ação | Teclado |
|------|---------|
| Mover | ←→ / A D |
| Pular | Espaço / W / ↑ |
| Correr | Shift (segurar) |
| Agachar | ↓ / S |
| Interagir | E / Z |

---

## 🔧 Erros Comuns e Soluções

**Erro: "Can't open file"** → Verifique que todos os scripts existem em `res://scripts/`

**Erro: "Invalid get index on base 'null'"** → O node filho não existe na cena.
Verifique a hierarquia e os nomes dos `@onready`.

**Sprite não aparece** → SVG não foi importado com Filter=Nearest. Reimportar.

**Parallax não funciona** → `ParallaxBackground` precisa ter `scroll_base_offset`
controlado pela câmera. A câmera deve ser filha direto de `/root`, não do player.

**Ichigo atravessa o chão** → O `CollisionShape2D` do Ground (shape `rs_ground`)
precisa ter position.y = 0 no Ground, que está em y=218.

---

## 🎨 Paleta de Cores da Ichigo (referência)

| Elemento | Hex |
|----------|-----|
| Chapéu morango (base) | `#CC3230` |
| Chapéu morango (claro) | `#E04848` |
| Chapéu morango (escuro) | `#8A1C1C` |
| Sementes do morango | `#7A1414` |
| Folhas verdes | `#2D7030` |
| Macacão azul claro | `#4A6FA5` |
| Macacão azul escuro | `#3D5E8C` |
| Pele | `#F0D0A8` |
| Bochechas | `#F0A0A0` |
| Olhos | `#1A0E08` |
| Sapatos | `#5C3A1E` |
