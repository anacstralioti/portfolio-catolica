# GDD — Ichigo: Memórias do Oceano

> Documento de Design de Jogo (GDD) para *Ichigo: Memórias do Oceano* — jogo 2D com motor narrativo baseado em Máquinas de Estados Finitos (FSM) e uso explícito de estruturas de dados.

---

## Objetivo do Repositório
Este repositório contém o Documento de Design de Jogo (GDD) para *Ichigo: Memórias do Oceano*, cobrindo mecânicas, narrativa, níveis, arte, áudio, tecnologia e plano de testes. O GDD é destinado a guiar o desenvolvimento do protótipo e a documentação do TCC/portfólio.

---

# Sumário

1. [Informações Gerais](#1-informações-gerais)  
2. [Mecânicas de Jogo](#2-mecânicas-de-jogo)  
3. [Narrativa](#3-narrativa)  
4. [Design de Níveis](#4-design-de-níveis)  
5. [Arte e Estilo Visual](#5-arte-e-estilo-visual)  
6. [Áudio](#6-áudio)  
7. [Progresso e Salvamento](#7-progresso-e-salvamento)  
8. [Monetização](#8-monetização)  
9. [Testes e Qualidade](#9-testes-e-qualidade)  
10. [Conclusão e Próximos Passos](#10-conclusão-e-próximos-passos)  
11. [Apêndices técnicos: FSM e Estruturas de Dados](#11-apêndices-técnicos-fsm-e-estruturas-de-dados)

---

## 1. Informações Gerais

### 1.1. Título do Jogo
- **Título:** Ichigo: Memórias do Oceano

### 1.2. Plataforma
- **Plataforma alvo:** PC (Windows, Linux), exportável para Web/HTML5.
- **Engine:** Godot Engine 4.x (GDScript)

### 1.3. Gênero
- **Gênero:** Plataforma 2D / Jogo narrativo artístico (walking + light puzzle)

### 1.4. Público-Alvo
- Jogadores de jogos independentes e narrativos (15+)
- Estudantes e pesquisadores de game design e engenharia de software
- Público interessado em narrativas simbólicas e experiências contemplativas

### 1.5. Visão Geral do Jogo
- *Ichigo: Memórias do Oceano* é um jogo 2D side-scroller onde o jogador controla Ichigo, uma criança sobrevivente de um tsunami. O mundo muda *continuamente* conforme o personagem caminha para a direita: três grandes momentos (Ecos do Silêncio → Ruínas do Oceano → Horizonte de Esperança). As mudanças são geridas por um **motor narrativo** implementado como uma **FSM** construída com estruturas de dados (listas, filas, dicionários/grafos). Colecionáveis têm função prática e simbólica (resolver obstáculos e avançar) e a experiência é construída sem diálogos extensos — com frases curtas e simbolismo.

---

## 2. Mecânicas de Jogo

### 2.1. Regras Básicas
- O jogador controla Ichigo em visão lateral 2D. Objetivo final: alcançar a casa no horizonte (reencuentro com os pais).
- O personagem deve progredir para a direita (exploração lateral permitida à esquerda).
- Obstáculos bloqueiam o caminho; cada obstáculo tem um **objeto funcional** que permite superá-lo (ex.: pá para tapar buraco).
- Colecionáveis são necessários em pontos-chave (por exemplo, colecionar conchas para abrir a rocha final).
- Não há sistema de combate complexo. O jogo prioriza resolução de obstáculos e narrativa ambiental.
- Sistema de checkpoints: 1–2 por “fase/trecho” (total de ~5 checkpoints no mapa).

### 2.2. Controles
- **PC (teclado):**
  - Setas / A D — mover (left/right)
  - W / Espaço — pular
  - S / Ctrl — interagir / usar item (quando aplicável)
  - E — pegar / inspecionar objeto
  - Esc — menu / pause
- O design de controle é simples e responsivo; todas as ações têm feedback visual e sonoro.

### 2.3. Objetivos e Metas
- Objetivo primário: Guiar Ichigo até a casa no horizonte, reunindo objetos simbólicos e superando obstáculos.
- Objetivos secundários: coletar conchas e memórias que desbloqueiam pontos de progressão e aprimoram final narrativo.

### 2.4. Sistema de Pontuação
- Não há foco em “pontuação” competitiva. Sistema de registro de colecionáveis:
  - Cada concha / item é contado e exibido no HUD (meta: coleção completa ativa evento final).
- Estatísticas gravadas para telemetria: tempo de fase, itens coletados, número de mortes/voltas a checkpoint.

### 2.5. Mecânicas de Interação
- Pegar (E): colecionáveis/objetos.
- Usar (S/Ctrl): ativa os objetos no mundo (ex.: usar pá no buraco).
- Interagir com pontos narrativos: desencadeia frases curtas no HUD e efeitos de estado (mudança de cor, música).
- Checkpoints: tocar para salvar estado; fracasso retrocede ao checkpoint.

### 2.6. Sistemas de Progressão e Recompensas
- Progressão linear visual (mundo contínuo em três trechos).
- Recompensas são funcionais (objetos que desbloqueiam travas) e narrativas (frases + visuais).
- Reuso do motor narrativo para alterar spawn rate, obstáculos e trilha sonora conforme o estado do mundo.

### 2.7. Inteligência Artificial (IA)
- IA básica para **hazards**:
  - Caranguejos: padrão simples de marcha lateral; colidir empurra o jogador.
  - Animais assustados (fase 2): movimento errático, empurram Ichigo se em rota de colisão.
- IA não é adversarial: comportamento previsível e telegráfico (sinais visuais/sonoros).

### 2.8. Dinâmicas de Jogo
- Mecânica principal = exploração + resolução de obstáculos com objetos.
- Dinâmicas emergentes: escolha por voltar para pegar objetos opcionais vs seguir direto; gerenciamento de recursos (usar objeto no local certo).

### 2.9. Economia do Jogo
- Não aplicável (jogo não possui microtransações). Inventário simples de itens (máx 6 slots), todos coletáveis no mundo.

---

## 3. Narrativa

### 3.1. História Principal (resumo)
- Ichigo sobrevive a um tsunami. A jornada é sobre atravessar o mundo transformado (silêncio, ruína, renascimento) até reencontrar a casa e os pais. A história é contada por **texto curto** em momentos-chave e por alterações ambientais.

### 3.2. Personagens
1. **Ichigo** — protagonista infantil, sem gênero definido (design neutro). Curioso, resiliente.
2. **Pais (silhuetas)** — não jogáveis; aparecem no final como objetivo emocional.
3. **Ambiente** — "personificado" (mar, vento, destroços) que atua quase como personagem narrativo.

### 3.3. Cenários
- Três trechos contínuos (veja seção de níveis):
  - *Ecos do Silêncio* — praia com destroços, calma enganosa.
  - *Ruínas do Oceano* — destruição concreta, obstáculos reais.
  - *Horizonte de Esperança* — renascimento com vegetação e luz.

### 3.4. Missões e Quests
- Missões principais são implícitas: avançar no mapa, coletar objetos necessários.
- Não há quests secundárias convencionais; objetivos opcionais: colecionar todas as conchas para desbloqueio simbólico final.

### 3.5. Roteiro e Diálogos (excertos)
- Textos curtos exibidos em momentos-chave:
  - “Um tsunami invade a casa de Ichigo…”
  - “Sem seus pais à vista, Ichigo se sente só.”
  - “Mesmo molhado, ainda guarda o calor de casa.”
  - “No horizonte… uma luz familiar.”
- Não há dublagem; todo o texto é minimalista e poético.

---

## 4. Design de Níveis

### 4.1. Estrutura dos Níveis
- O “nível” é um único mapa horizontal contínuo dividido em trechos (fase1 → fase2 → fase3). Cada trecho tem checkpoints. Total de obstáculos planejados: 21 (6/8/7 por trecho).

### 4.2. Mapas e Layouts
- **Mapa contínuo (visão lateral 2D, 16:9):**
  - **Start (left)**: Ichigo desperta na areia — *Ecos do Silêncio* (tutorial embutido).
  - **Middle**: transição gradual para *Ruínas do Oceano* (céu escurecendo → tempestade visual).
  - **End**: progressão para *Horizonte de Esperança* — subida da duna e casa ao fundo.
- **Blueprints**: para cada trecho haverá 1) background clean e 2) blueprint anotado com legendas (Spawn, Obstacles, Collectibles, Checkpoints, Goal).

### 4.3. Desafios e Puzzles (detalhado por obstáculo)
> *Fase 1 — Ecos do Silêncio* (6 obstáculos)
1. **Tronco (x1)** — pular; concha luminosa acima do tronco; falha = recuo leve.  
2. **Buraco areia (x1)** — necessita **Pá** (coletável anterior); uso: preencher; falha = não atravessa.  
3. **Caranguejos (x2)** — desviar/pular; **Balde** pode afastar.  
4. **Destroços leves (x1)** — empurrar para abrir caminho; concha próxima (contagem).  
5. **Poça rasa (x1)** — movimento lento; brinquedo cria boia: aumenta velocidade.

> *Fase 2 — Ruínas do Oceano* (8 obstáculos)
1. **Poça de lama (x1)** — necessita botas (coletável); atola se não tiver.  
2. **Árvore caída (x1)** — usar corda para escalar (coletável).  
3. **Destroços com pregos (x2)** — não tocar; lanterna revela caminho seguro.  
4. **Barco virado (x1)** — ursinho ativa memória, barco desliza; tempo-limited.  
5. **Animais assustados (x1)** — usar pano para acalmar.  
6. **Ventania (x1)** — bandeira guia o vento; andar contra reduz velocidade.

> *Fase 3 — Horizonte de Esperança* (7 obstáculos)
1. **Pedras (x2)** — pular; cada flor coletada aumenta saturação.  
2. **Riacho pequeno (x1)** — foto mostra ponto de travessia.  
3. **Buraco profundo (x1)** — bola cria ponte de luz.  
4. **Riacho largo (x1)** — livro transforma páginas em pedras flutuantes.  
5. **Rocha final (x1)** — só abre com coleção completa de conchas.

Obs.: números (x1/x2) são contagem sugerida por trecho; durante implementação pode ajustar para ritmo.

### 4.4. Fluxo dos Níveis
- Checkpoints automáticos em pontos de segurança (total ~5).
- Transições visuais contínuas (gradiente de cor, partículas, trilha sonora adaptativa) — sem telas de carregamento entre trechos.
- Progressão linear com possibilidade de retorno para buscar itens opcionais.

### 4.5. Balanceamento de Dificuldade
- Fase 1: tutorial gradual, baixa dificuldade.  
- Fase 2: pico de dificuldade (timings e hazards temporais).  
- Fase 3: dificuldade moderada, foco em resolução criativa (uso de itens).  
- Playtests iterativos para ajustar número de obstáculos e janelas de tempo (meta: média de conclusão por fase 2–3 minutos).

---

## 5. Arte e Estilo Visual

### 5.1. Estilo Artístico
- **Traço:** estilizado/cartoon indie com pintura digital (concept-art feel).  
- **Abordagem:** camadas de parallax para profundidade; elementos com silhuetas fortes para leitura de gameplay.

### 5.2. Personagens e Animações
- **Ichigo:** chibi / simplificado, paleta suave; sprites: idle, walk (4 frames), run (6 frames), jump (2-3 frames), interact.  
- **Animações:** fluídas, sem excesso; feedback claro para pulo, pegar e uso de item.

### 5.3. Cenários e Ambientes
- 3 conjuntos de BGs (clean + blueprint anotado).  
- Elementos interativos (troncos, buracos, destroços) em camada fg; objetos decorativos em bg.

### 5.4. Interface do Usuário (UI)
- HUD minimalista: contador de colecionáveis (ícone + número), indicador de item equipado, ícone de checkpoint.  
- Caixa de texto translúcida para frases curtas (aparece no canto superior/esquerdo por 3–4s).

### 5.5. Paleta de Cores
- *Ecos do Silêncio:* azuis pálidos e cinzas suaves.  
- *Ruínas do Oceano:* tons frios, contraste alto, saturação abaixada.  
- *Horizonte de Esperança:* tons quentes (dourado, verde suave), saturação aumenta progressivamente.

---

## 6. Áudio

### 6.1. Trilha Sonora
- Trilha adaptativa com camadas (vertical mixing): 
  - Layer calmo, layer tensão, layer esperança — mixado conforme FSM.
- Compositor: trilhas simples e melódicas, instrumentos acústicos e pads digitais.

### 6.2. Efeitos Sonoros
- FX por ação: passo na areia, splash, pulo, coletar item, usar item, ambiente (vento, chuva).  
- Sons de feedback (ping ao coletar, som grave ao falhar em hazard).

### 6.3. Dublagem
- Não há dublagem; fala é expressa em texto curto.

### 6.4. Ambiente Sonoro
- Ambientes com SFX 3D estéreo (vento direcional, ondas ao longe, trovões pontuais).

---

## 7. Progresso e Salvamento

### 7.1. Sistema de Progressão
- O progresso é representado por posição no mapa (x coordinate contínua) + inventário (itens coletados).  
- Requisitos para eventos (ex.: abrir rocha final) checados via inventário e estado atual da FSM.

### 7.2. Sistema de Salvamento
- Salvamento automático em checkpoints (arquivo local JSON).  
  - Dados salvos: posição do checkpoint, itens coletados, estado atual das conchas (bitmask), progresso de narrativa.  
- Opção de reiniciar nível/voltar ao menu.

---

## 8. Monetização

### 8.1. Modelo de Negócio
- Projeto acadêmico / protótipo — sem monetização prevista.  
- Se houver versão comercial futura: possível venda única (pay-to-download) e/ou venda de cosmetic DLC. Não há consumíveis que impactem gameplay.

### 8.2. Itens Pagos
- Não aplicável na versão do TCC. Qualquer modelo futuro será planejado respeitando licenciamento dos assets.

---

## 9. Testes e Qualidade

### 9.1. Testes de Jogo
- **Testes Unitários (técnicos):** FSM transitions, validação de eventos (testes em GDScript/pseudotests).  
- **Testes de Integração:** troca de estados altera cenários, trilha e spawn.  
- **Playtests (usability):** 12–20 jogadores (testes de compreensão narrativa e dificuldade).  
- **A/B:** versão com motor narrativo ativo vs inativo (medir reconhecimento de mudança e engajamento).

**Cronograma de testes (sugestão):**
- Protótipo alfa (mecânica): 2 semanas
- Testes internos (ajustes): 2 semanas
- Playtest externos (12–20 jogadores): 2 semanas
- Iterações finais: 2 semanas

### 9.2. Feedback dos Jogadores
- Coleta via formulário (Likert scale + comentários abertos).  
- Métricas: compreensão narrativa (percentual que reconhece mudança), taxa de conclusão, taxa de repetição de checkpoints.

---

## 10. Conclusão e Próximos Passos

### 10.1. Sumário
- *Ichigo* propõe um motor narrativo baseado em FSM e estruturas de dados aplicadas a um jogo 2D de plataforma narrativo. O diferencial é a mudança contínua do ambiente guiada por estados ambientais.

### 10.2. Próximos Passos
1. **Criação de Assets:** sprites, backgrounds (clean + blueprint), SFX.  
2. **Implementação FSM:** modelagem com estruturas de dados e integração com áudio/visual.  
3. **Integração de Níveis:** montar mapa contínuo e checkpoints.  
4. **Testes:** correções e balanceamento.  
5. **Playtests:** coleta de dados e ajustes finais.  

---

## 11. Apêndices técnicos: FSM e Estruturas de Dados

### 11.1. Visão Geral do Motor Narrativo (FSM)
- **Estados principais:** `EcosDoSilencio`, `RuinasDoOceano`, `HorizonteDeEsperanca`.  
- **Eventos:** `collect_item`, `reach_checkpoint`, `use_item`, `time_elapsed`, `player_action`.  
- **Transições:** implementadas via tabela de transições (dicionário/hashmap).  
- **Processamento de eventos:** fila (queue) garante ordem e debounce de eventos.

### 11.2. Mapeamento FSM ↔ Estrutura de Dados
| Elemento FSM | Estrutura de Dados | Uso no Jogo |
|--------------|--------------------|-------------|
| Estados | Lista / Array | Guarda estados possíveis e iterações |
| Eventos | Fila (Queue) | Enfileira ações externas e internas |
| Transições | Dicionário (HashMap) | Mapeia (estado, evento) -> próximo estado |
| Fluxo narrativo | Lista encadeada | Sequência de textos/legendas por checkpoint |
| Histórico | Pilha (Stack) | Permite rollback (undo) para debug ou “voltar” |
| Topologia FSM | Grafo (adjacency list) | Permite caminhos alternativos/expansões |

### 11.3. Exemplo simplificado (pseudocódigo)
```python
# estados
states = ["EcosDoSilencio","RuinasDoOceano","HorizonteDeEsperanca"]

# transicoes: transicoes[current_state][event] = next_state
transicoes = {
  "EcosDoSilencio": {"collect_all_shells":"RuinasDoOceano", "time_elapsed":"RuinasDoOceano"},
  "RuinasDoOceano": {"use_rock_key":"HorizonteDeEsperanca"},
  "HorizonteDeEsperanca": {}
}

# fila de eventos
event_queue = Queue()
event_queue.enqueue(("collect_item","concha"))

# processamento
while not event_queue.empty():
  event = event_queue.dequeue()
  current = game_state.current
  if event in transicoes[current]:
    game_state.current = transicoes[current][event]
    apply_state_effects(game_state.current)  # altera cor, spawn, música
