# GDD — Ichigo: Memórias do Oceano

> Documento de Design de Jogo (GDD) para *Ichigo: Memórias do Oceano* — jogo 2D com motor narrativo baseado em Máquinas de Estados Finitos (FSM) e uso explícito de estruturas de dados.

---

## Objetivo do Repositório
Este repositório contém o Documento de Design de Jogo (GDD) para *Ichigo: Memórias do Oceano*, cobrindo mecânicas, narrativa, níveis, arte, tecnologia e plano de testes. O GDD é destinado a guiar o desenvolvimento do protótipo e a documentação do portfólio.

---

# Sumário

1. [Informações Gerais](#1-informações-gerais)  
2. [Mecânicas de Jogo](#2-mecânicas-de-jogo)  
3. [Narrativa](#3-narrativa)  
4. [Design de Níveis](#4-design-de-níveis)  
5. [Arte e Estilo Visual](#5-arte-e-estilo-visual)  
6. [Áudio](#6-áudio)  
7. [Progresso e Salvamento](#7-progresso-e-salvamento)  
8. [Testes e Qualidade](#8-testes-e-qualidade)

---

## 1. Informações Gerais

### 1.1. Título do Jogo
- **Título:** Ichigo: Memórias do Oceano

### 1.2. Plataforma
- **Plataformas exportadas:** Windows (.exe) (hospedado no itch.io)
- **Engine:** Godot Engine 4.5 / GDScript
- **Resolução base:** 320×180 px (pixel art, escala 3×)

### 1.3. Gênero
- **Gênero:** Plataforma 2D / jogo narrativo artístico (walking + light puzzle)

### 1.4. Público-Alvo
- Jogadores de jogos independentes e narrativos;
- Estudantes e pesquisadores de game design e engenharia de software;
- Público interessado em narrativas simbólicas e experiências contemplativas.

### 1.5. Visão Geral do Jogo
*Ichigo: Memórias do Oceano* é um jogo 2D onde o jogador controla Ichigo, uma criança sobrevivente de um tsunami. O mundo muda conforme o personagem caminha pela praia: clima, obstáculos e narrativa são controlados por um **motor narrativo** implementado como uma **FSM** com cinco estados. A fase implementada é *Ecos do Silêncio*. Colecionáveis têm função prática e simbólica, e a experiência é construída sem diálogos extensos, apenas com frases curtas e simbolismo ambiental.

### 1.6. Estado de Desenvolvimento
- **Fase 1 — Ecos do Silêncio:** implementada e exportada.

---

## 2. Mecânicas de Jogo

### 2.1. Regras Básicas
- O jogador controla Ichigo em visão lateral 2D, com objetivo: alcançar o fim da fase;
- Obstáculos bloqueiam o caminho e cada um tem um objeto funcional que permite superá-lo (pá para buracos de areia, balde para interações com castelo de areia);
- Colecionáveis (conchas, foto, carta, colar) têm valor narrativo e funcional;
- Não há sistema de combate, o jogo prioriza exploração e narrativa ambiental;
- Sistema de checkpoints automáticos.

### 2.2. Controles
- **Movimento:** Setas / A D para mover (esquerda/direita)
- **Correr:** Shift, segurar para correr
- **Pular:** W / Espaço
- **Interagir / Usar item:** E
- **Equipar item:** Teclas 1–8 (seleciona slot do inventário)
- **Pause:** Esc, abre menu de pausa
- **Ver foto coletada:** Selecionar slot da foto + E
- **Reler carta coletada:** Selecionar slot da carta + E

### 2.3. Objetivos e Metas
- **Primário:** Guiar Ichigo até o fim da fase, coletando memórias e superando obstáculos;
- **Secundários:** Coletar todas as conchas e reler foto e carta coletadas.

### 2.4. Sistema de Inventário
- Barra de inventário com 8 slots no rodapé da tela;
- Itens disponíveis na fase 1: concha (×N), pá, balde, foto, carta (diary), colar;
- Item ativo é exibido com borda dourada; troca via teclas 1–8;
- Itens podem ser re-examinados a qualquer momento pelo inventário (foto e carta abrem overlay).

### 2.5. Mecânicas de Interação
- **Coletar:** aproximar do objeto → E (collectible entra no inventário automaticamente ao tocar);
- **Usar item no ambiente:** E com item equipado próximo ao objeto compatível (ex: pá + buraco de areia);
- **Examinar memória:** E próximo a objeto de memória, ou pelo inventário após coletado;
- **Checkpoint:** tocar no poste de checkpoint → salva automaticamente.

### 2.6. Sistemas de Progressão
- FSM com 5 estados controla clima, narrativa e obstáculos em tempo real;
- Progressão medida por posição X no mapa (0–6400 px);
- Transições de estado em 15% / 40% / 65% / 85% do mapa.

---

## 3. Narrativa

### 3.1. História Principal
Ichigo sobrevive a um tsunami. A jornada simbólica pela praia representa o processo de elaborar o trauma: da negação ao confronto e à resolução. A história é contada por frases curtas em momentos-chave e por alterações ambientais automáticas.

### 3.2. Motor Narrativo — FSM

| Estado | Progresso | Clima | Tom Narrativo |
|---|---|---|---|
| INICIO | 0–15% | Sol claro | Quietude, calma enganosa |
| RECONHECIMENTO | 15–40% | Levemente nublado | Memórias começam a surgir |
| LEMBRANCA | 40–65% | Nublado, frio | Melancolia, flashbacks |
| CONFRONTO | 65–85% | Chuva, escuro | Tensão, medo |
| RESOLUCAO | 85–100% | Clareia, dourado | Aceitação, esperança |

Cada transição de estado dispara simultaneamente: nova fala narrativa, mudança de tint de cor e ajuste de obstáculos.

### 3.3. Personagens
1. **Ichigo:** protagonista infantil com chapéu de morango e design neutro;
2. **Pais:** presentes apenas em memórias (foto, carta) e como objetivo emocional;
3. **Ambiente:** o mar, clima e destroços atuam como personagem narrativo.

### 3.4. Objetos de Memória (fase 1)
- **Foto:** abre overlay com imagem + legenda, re-examinável pelo inventário;
- **Carta (diary):** abre overlay com página de diário manuscrito, re-examinável;
- **Caixinha de música:** ao interagir, toca melodia procedural + abre flashback;
- **Colar:** item narrativo coletável.

### 3.5. Roteiro — Fase 1: Ecos do Silêncio

- **Estado INICIO:** "A praia parece a mesma. Mas não é."
- **Estado RECONHECIMENTO:** "O pingente de morango dela. Eu costumava perder esse pingente toda semana."
- **Estado LEMBRANCA:** "A caixinha de música ainda toca. Como ela ainda toca?"
- **Estado CONFRONTO:** "O céu ficou do mesmo jeito naquele dia."
- **Estado RESOLUCAO:** "Talvez o mar não seja só destruição."

### 3.6. Cena de Transição — Tsunami
Cutscene procedural ao fim da fase 1: onda se aproxima, derruba a palmeira, varre a placa, inunda a praia. Efeitos: tremor de câmera, relâmpagos visuais com trovões procedurais, chuva e vento em loop. Renderizada 100% por código com `draw_polygon()` e `draw_set_transform()`.

---

## 4. Design de Níveis

### 4.1. Estrutura da Fase 1, implementada
- Mapa horizontal contínuo: 6400 px de largura;
- Checkpoints automáticos;
- Spawn de objetos determinístico via seed aleatória por sessão;
- Itens e obstáculos: buracos de areia (pá necessária), caranguejos, poças, troncos, objetos de memória.

### 4.2. Objetos do Mundo (fase 1)
| Tipo | Script | Comportamento |
|---|---|---|
| Collectible | `collectible.gd` | Bob animado, coletado ao tocar |
| Sand Hole | `sand_hole.gd` | Bloqueio, pá remove |
| Crab | `crab.gd` | NPC animado, spawn determinístico |
| Puddle | `puddle.gd` | Reduz velocidade em 45% |
| Memory Object | `memory_object.gd` | Abre overlay de foto/diary/flashback |
| Checkpoint | `checkpoint.gd` | Salva progresso ao tocar |
| Music Box | `music_box.gd` | Toca melodia + flashback |

### 4.3. Fluxo da Fase
1. Tela inicial → selecionar slot → phase_intro → fase 1
2. Jogador percorre o mapa; FSM muda clima e narrativa automaticamente
3. Ao atingir 100% → cutscene do tsunami → phase_intro fase 2 (placeholder)

---

## 5. Arte e Estilo Visual

### 5.1. Estilo Artístico
- **Traço:** pixel art, resolução nativa 320×180 px, escala 3× na tela
- **Canvas:** `stretch_mode = viewport`, mantém proporção e pixelização

### 5.2. Personagem — Ichigo
- Chapéu de morango característico
- Animações: idle, walk, run, jump, fall, crouch, hold
- Bob suave sincronizado com velocidade de movimento
- Partículas de poeira ao correr

### 5.3. Interface do Usuário (UI)

**Tela Inicial:**
- Background pixel art de pôr do sol na praia;
- Título "ICHIGO" (font_size 16, dourado, shimmer animado em loop);
- Subtítulo "Memórias do Oceano" (font_size 8);
- Menu no lado direito: Novo Jogo / Continuar / Créditos / Sair
- Seleção por teclado (W/S ou setas) e mouse.

**HUD em jogo:**
- Barra de inventário centralizada no rodapé (8 slots, 22×22 px cada);
- Hint acima do inventário: "Selecione 1-8 para equipar o item correspondente";
- Barra de progresso no topo da tela;
- Narrativa: label centralizada com autowrap, posicionada em 56–82% da altura.

### 5.4. Paleta de Cores por Estado FSM
- **INICIO:** azuis pálidos, areia quente, sol claro;
- **RECONHECIMENTO:** leve véu azul-acinzentado;
- **LEMBRANCA:** tint frio e escurecido;
- **CONFRONTO:** escuro, chuva, CPUParticles ativas;
- **RESOLUCAO:** tint dourado suave, chuva cessa.

---

## 6. Áudio

### 6.1. Abordagem
Todo o áudio é gerado **proceduralmente** em tempo real via `AudioStreamWAV` e `AudioStreamGenerator`, sem nenhum arquivo de áudio externo no projeto. Implementado em `scripts/procedural_sfx.gd` (classe estática).

### 6.2. Sons Implementados

| Função | Método | Descrição |
|---|---|---|
| Passo na areia | `footstep_sand()` | Ruído LP + batida grave 90 Hz, 4 variações |
| Coletar item | `item_pickup()` | Chirp ascendente 380→760 Hz |
| Checkpoint | `checkpoint_ping()` | Jingle Dó5→Mi5 |
| Tapar buraco | `sand_fill()` | Whoosh + thud grave |
| Caixinha de música | `music_box_melody()` | Melodia 7 notas em Lá menor, timbre de sino |
| Trovão | `thunder()` | Estalo HP + rumble LP 2s, pitch aleatório |
| Tempestade (loop) | `storm_loop()` | Chuva + vento, seed fixo, loop 3s |
| Ondas do mar (loop) | `ocean_loop()` | Swell rítmico, seed fixo, loop 4s |

### 6.3. Música Ambiente
Drone procedural em Lá menor gerado em tempo real via `AudioStreamGenerator` (82 Hz + 110 Hz + 164 Hz + shimmer LFO 0.07 Hz). Ondas do mar tocam em camada separada durante toda a fase 1.

### 6.4. Áudio no Tsunami
- Loop de tempestade inicia ao entrar na cutscene;
- Trovão disparado a cada relâmpago visual (cooldown 2.8s, pitch variável).

---

## 7. Progresso e Salvamento

### 7.1. Sistema de Salvamento
- **3 slots independentes** em JSON local (`user://fase1_save_slot{1,2,3}.json`);
- Dados salvos: posição do checkpoint, itens do inventário, progresso FSM, seed do mundo;
- Salva automaticamente ao tocar em um checkpoint;
- Slot selecionado na tela inicial e slots podem ser apagados pelo menu "Continuar".

### 7.2. Dados Persistentes (GameGlobal — Autoload)
- `current_save_slot`: slot ativo entre cenas;
- `next_phase_number` / `next_phase_name`: controla qual fase carregar;
- `photo_texture` / `photo_caption`: textura e legenda da foto coletada (para reabrir pelo inventário);
- `has_diary`: flag para reabrir a carta pelo inventário

---

## 8. Testes e Qualidade

### 8.1. Testes Técnicos
- Transições de FSM validadas manualmente (5 estados, 4 transições);
- Spawn determinístico validado: mesma seed gera mesma posição de objetos;
- Save/load testado nos 3 slots com dados corrompidos e slots vazios;
- Framework de testes: GUT (Godot Unit Testing).

### 8.2. Playtesting — Resultados

Sessão realizada com 3 participantes (via formulário Google Forms).

**Métricas principais:**

| Métrica | Resultado |
|---|---|
| Perceberam mudança de clima/atmosfera | 3 de 4 (75%) |
| Entenderam a narrativa de Ichigo | 3 de 4 (75%) |
| Controlaram bem o personagem | 4 de 4 (100%) |
| Nota média | 4,0 / 5,0 |

**Principais feedbacks e ações tomadas:**

| Feedback | Ação |
|---|---|
| Não sabia como equipar itens | Adicionado hint "Selecione 1-8 para equipar o item correspondente" acima do inventário |
| Não conseguia reler foto e carta após fechar | Implementado: pressionar E com item selecionado no inventário reabre o item |
| Não havia aviso de como fechar a carta | Adicionado hint "[E] Fechar carta" dentro da página |

**Destaque positivo:** A cutscene do tsunami foi elogiada pelos 3 participantes.

### 8.3. Exportação e Distribuição
- **Windows:** `.exe` + `.pck` exportados via Godot 4.5 (template Windows Desktop x86_64);
- Hospedagem: itch.io;
- Classificação: Livre (sem violência, sem dados pessoais coletados — LGPD).
