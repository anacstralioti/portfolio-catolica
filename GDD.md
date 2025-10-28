# GDD — Ichigo: Memórias do Oceano

> Documento de Design de Jogo (GDD) para *Ichigo: Memórias do Oceano* — jogo 2D com motor narrativo baseado em Máquinas de Estados Finitos (FSM) e uso explícito de estruturas de dados.

---

## Objetivo do Repositório
Este repositório contém o Documento de Design de Jogo (GDD) para *Ichigo: Memórias do Oceano*, cobrindo mecânicas, narrativa, níveis, arte, áudio, tecnologia e plano de testes. O GDD é destinado a guiar o desenvolvimento do protótipo e a documentação do portfólio.

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

---

## 1. Informações Gerais

### 1.1. Título do Jogo
- **Título:** Ichigo: Memórias do Oceano

### 1.2. Plataforma
- **Plataforma alvo:** PC
- **Engine:** Godot Engine (GDScript)

### 1.3. Gênero
- **Gênero:** Plataforma 2D / Jogo narrativo artístico (walking + light puzzle)

### 1.4. Público-Alvo
- Jogadores de jogos independentes e narrativos
- Estudantes e pesquisadores de game design e engenharia de software
- Público interessado em narrativas simbólicas e experiências contemplativas

### 1.5. Visão Geral do Jogo
- *Ichigo: Memórias do Oceano* é um jogo 2D onde o jogador controla Ichigo, uma criança sobrevivente de um tsunami. O mundo muda conforme o personagem caminha para a direita: três grandes momentos (Ecos do Silêncio → Ruínas do Oceano → Horizonte de Esperança). As mudanças são geridas por um **motor narrativo** implementado como uma **FSM** construída com estruturas de dados. Colecionáveis têm função prática e simbólica (resolver obstáculos e avançar) e a experiência é construída sem diálogos extensos — com frases curtas e simbolismo.

---

## 2. Mecânicas de Jogo

### 2.1. Regras Básicas
- O jogador controla Ichigo em visão lateral 2D. Objetivo final: alcançar a casa no horizonte (reencontro com os pais);
- O personagem deve progredir para a direita (exploração lateral poderá ser permitida à esquerda);
- Obstáculos bloqueiam o caminho, de forma que cada obstáculo tem um **objeto funcional** que permite superá-lo (por exemplo, pá para tapar buraco);
- Colecionáveis são necessários em pontos-chave (por exemplo, colecionar conchas para abrir a rocha final);
- Não há sistema de combate complexo, o jogo prioriza resolução de obstáculos e narrativa ambiental;
- Sistema de checkpoints: 1–2 por “fase/trecho” (total de cerca de 5 checkpoints no mapa).

### 2.2. Controles
- **PC (teclado):**
  - Setas / A D — mover (esquerda/direita);
  - W / Espaço — pular;
  - S / Ctrl — interagir / usar item;
  - E — pegar / inspecionar objeto;
  - Esc — menu / pause;
- O design de controle é simples e responsivo; todas as ações devem ter feedback visual e sonoro.

### 2.3. Objetivos e Metas
- Objetivo primário: Guiar Ichigo até a casa no horizonte, reunindo objetos simbólicos e superando obstáculos.
- Objetivos secundários: Coletar conchas e memórias que desbloqueiam pontos de progressão e aprimoram final narrativo.

### 2.4. Sistema de Pontuação
- Não há foco em “pontuação” competitiva. Mas conta-se com um sistema de registro de colecionáveis:
  - Cada concha / item é contado e exibido no HUD (meta: coleção completa ativa evento final).
- Estatísticas gravadas para telemetria: tempo de fase, itens coletados.

### 2.5. Mecânicas de Interação
- Pegar (E): colecionáveis/objetos;
- Usar (S/Ctrl): ativa/permite utilizar os objetos no mundo (por exemplo, usar pá no buraco);
- Interagir com pontos narrativos: desencadeia frases curtas e efeitos de estado (mudança de cor, música).
- Checkpoints: tocar para salvar estado; fracasso retrocede ao checkpoint.

### 2.6. Sistemas de Progressão e Recompensas
- Progressão linear visual (mundo contínuo em três trechos);
- Recompensas são funcionais (objetos que desbloqueiam travas) e narrativas (frases + visuais);
- Reuso do motor narrativo para alterar spawn rate, obstáculos e trilha sonora conforme o estado do mundo.

### 2.7. Dinâmicas de Jogo
- Mecânica principal = exploração + resolução de obstáculos com objetos;
- Dinâmicas emergentes: escolha por voltar para pegar objetos opcionais vs seguir direto; gerenciamento de recursos (usar objeto no local certo).

### 2.8. Economia do Jogo
- Não aplicável (jogo não possui microtransações). Inventário simples de itens (de, no máximo, 6 slots), todos coletáveis no mundo.

---

## 3. Narrativa

### 3.1. História Principal (resumo)
- Ichigo sobrevive a um tsunami. A jornada é sobre atravessar o mundo transformado até reencontrar a casa e os pais. A história é contada por **textos curtos** em momentos-chave e por alterações ambientais.

### 3.2. Personagens
1. **Ichigo** — protagonista infantil, sem gênero definido (design neutro);
2. **Pais (silhuetas)** — não jogáveis; aparecem no final como objetivo emocional;
3. **Ambiente** — "personificado" (mar, vento, destroços) que atua quase como personagem narrativo;

### 3.3. Cenários
- Três trechos contínuos:
  - *Ecos do Silêncio* — praia com destroços, calma enganosa;
  - *Ruínas do Oceano* — destruição concreta, obstáculos reais;
  - *Horizonte de Esperança* — renascimento com vegetação e luz.

### 3.4. Missões e Quests
- Missões principais são implícitas: avançar no mapa, coletar objetos necessários;
- Não há quests secundárias convencionais; objetivos opcionais: colecionar todas as conchas para desbloqueio simbólico final;

### 3.5. Roteiro e Diálogos
- Fase 1 — Ecos do Silêncio (Ambiente: praia calma, céu cinza-azulado, som distante do mar)
  - **Ato 1 — Despertar**:
    - [Texto na tela]: “Um tsunami invade a casa de Ichigo...” + “Sem seus pais à vista, Ichigo se sente só.”
    - Ichigo (em pensamento): “A água... levou tudo...” + “Mas... ainda ouço o som do mar.” + “Será que eles estão lá fora... me esperando?”
  - **Ato 2 — Primeiros Passos**:
    - Ao coletar uma concha: “Essa concha... igual àquela que eu encontrava com papai e mamãe.”
    - Ao passar por troncos e poças: “Preciso atravessar... com cuidado.”
    - Ao encontrar brinquedo quebrado: “Meu baldinho... talvez ainda dê pra usar.” (usado para construir ponte sobre um buraco)
  - **Ato 3 — Transição para a fase 2**:
    - [Cena de transição]: Som: trovões distantes, vento aumenta.
    - [Texto na tela]: “As memórias se misturam ao medo.” + “O mar se agita novamente...”
    - Ichigo (em pensamento): “Por que o céu ficou tão escuro...?”

- Fase 2 — Ruínas do Oceano (Ambiente: céu tempestuoso, vento forte, objetos flutuando)
  - **Ato 1 — Reencontro com o Medo**:
    - [Texto na tela]: “O mar não esqueceu...”
    - Ichigo (em pensamento): “Tudo está quebrado... como se o tempo tivesse parado.” + “Eu lembro... o barulho, o medo, o vento levando tudo.” + “Mas... preciso continuar.”
  - **Ato 2 — Obstáculos Maiores**:
    - Ao ver um barco tombado: “Era o barco do velho Kaito... ele sempre sorria.”
    - Ao encontrar uma lanterna: “Posso usá-la para ver melhor.” (ativa caminho oculto)
    - Ao ver brinquedo flutuando (urso): “Meu ursinho... pensei que nunca mais o veria.” (coletar acalma a música)
    - Ao cair na lama (precisa de botas): “A lama puxa... mas não posso parar agora.”
  - **Ato 3 — Transição**:
    - [Cena de transição]: Som: trovões cessam, som suave de pássaros + Luz: o sol começa a atravessar as nuvens.
    - Ichigo (em pensamento): “O vento está mudando... talvez... eu também esteja.”

- Fase 3 — Horizonte de Esperança (Ambiente: cores quentes, flores, céu limpo)
  - **Ato 1 — Caminho da Luz**:
    - [Texto na tela]: “O oceano silencia, e a terra respira novamente.”
    - Ichigo (em pensamento): “As flores... voltaram.” + “O ar está leve... como se o mundo respirasse comigo.”
    - Ao encontrar foto rasgada: “Mamãe... papai... ainda estão aqui, em algum lugar.”
    - Ao achar livro encharcado: “Ainda consigo ler... é nossa história.”
    - Ao atravessar rio raso: “A água agora é calma... não quer mais me levar.”
  - **Ato 2 — Último Desafio**:
    - Obstáculo (grande pedra): “Ela é pesada... mas se eu juntar todas as conchas...” (abre passagem)
    - Ao subir duna final: “O sol... o som... algo familiar.”
  - **Ato 3 — Encerramento**
    - [Cena Final]: “Ichigo sobe a duna. O vento carrega o som de risadas conhecidas.” + “Ao longe, uma casa reconstruída. Duas silhuetas acenam.”
    - Ichigo (em pensamento): “Mamãe... papai... eu voltei.” + “O mar me trouxe de volta.”
    - [Tela final]: “FIM — Mas o oceano nunca esquece quem aprende a ouvi-lo.”

---

## 4. Design de Níveis

### 4.1. Estrutura dos Níveis
- O “nível” é um único mapa horizontal contínuo dividido em trechos (fase 1 → fase 2 → fase 3). Cada trecho tem checkpoints. Total de obstáculos planejados: 21 (6/8/7 por trecho).

### 4.2. Mapas e Layouts
- **Mapa contínuo (visão lateral 2D, 16:9):**
  - **Start (left)**: Ichigo desperta na areia — *Ecos do Silêncio* (tutorial embutido);
  - **Middle**: transição gradual para *Ruínas do Oceano* (céu escurecendo → tempestade visual);
  - **End**: progressão para *Horizonte de Esperança* — subida da duna e casa ao fundo;
- **Blueprints**: para cada trecho haverá 1) background clean e 2) blueprint anotado com legendas (Spawn, Obstacles, Collectibles, Checkpoints, Goal).

### 4.3. Desafios e Puzzles (detalhado por obstáculo)
> *Fase 1 — Ecos do Silêncio* (6 obstáculos)
1. **Tronco (x1)** — pular; concha luminosa acima do tronco; falha = recuo leve;
2. **Buraco areia (x1)** — necessita **Pá** (coletável anterior); uso: preencher; falha = não atravessa;
3. **Caranguejos (x2)** — desviar/pular; **Balde** pode afastar;
4. **Destroços leves (x1)** — empurrar para abrir caminho; concha próxima (contagem);
5. **Poça rasa (x1)** — movimento lento; brinquedo cria boia: aumenta velocidade.

> *Fase 2 — Ruínas do Oceano* (8 obstáculos)
1. **Poça de lama (x1)** — necessita botas (coletável); atola se não tiver;
2. **Árvore caída (x1)** — usar corda para escalar (coletável);
3. **Destroços com pregos (x2)** — não tocar; lanterna revela caminho seguro;
4. **Barco virado (x1)** — ursinho ativa memória, barco desliza; tempo-limited;
5. **Animais assustados (x1)** — usar pano para acalmar;
6. **Ventania (x1)** — bandeira guia o vento; andar contra reduz velocidade.

> *Fase 3 — Horizonte de Esperança* (7 obstáculos)
1. **Pedras (x2)** — pular; cada flor coletada aumenta saturação;
2. **Riacho pequeno (x1)** — foto mostra ponto de travessia;
3. **Buraco profundo (x1)** — bola cria ponte de luz;
4. **Riacho largo (x1)** — livro transforma páginas em pedras flutuantes; 
5. **Rocha final (x1)** — só abre com coleção completa de conchas.

### 4.4. Fluxo dos Níveis
- Checkpoints automáticos em pontos de segurança (total ~5);
- Transições visuais contínuas (gradiente de cor, partículas, trilha sonora adaptativa) — sem telas de carregamento entre trechos;
- Progressão linear com possibilidade de retorno para buscar itens opcionais.

### 4.5. Balanceamento de Dificuldade
- Fase 1: tutorial gradual, baixa dificuldade;
- Fase 2: pico de dificuldade (timings e hazards temporais);
- Fase 3: dificuldade moderada, foco em resolução criativa (uso de itens);
- Playtests iterativos para ajustar número de obstáculos e janelas de tempo (meta: média de conclusão por fase 2–3 minutos).

---

## 5. Arte e Estilo Visual

### 5.1. Estilo Artístico
- **Traço:** pixel art;
- **Ferramenta:** Aseprite para criação e animação de sprites.

### 5.2. Personagens e Animações
- **Ichigo:** paleta suave (tons de azul, areia e rosa-claro, com destaque para o cabelo e roupa).
- **Sprites principais:**
  - Walk (6 frames) – caminhada leve, com braços e cabeça acompanhando;
  - Run (8 frames) – movimento fluido;
  - Jump (3 frames) – impulso, ápice e aterrissagem;
  - Interact (4 frames) – curvar, empurrar ou pegar itens;
  - Tamanho base: 48x48px.

### 5.3. Cenários e Ambientes
- Cada fase (estado FSM) terá um conjunto de tilesets e planos de fundo:
  - Ecos do Silêncio: areia, conchas, mar calmo, luz difusa;
  - Ruínas do Oceano: céu escuro, ondas agressivas, destroços, chuva pixelada;
  - Horizonte de Esperança: luz dourada, flores surgindo, vegetação reconstituída.

### 5.4. Interface do Usuário (UI)
- **HUD minimalista:**
  - Contador de colecionáveis (ícone de concha + número);
  - Indicador de item ativo (pequeno slot no canto inferior direito);
  - Ícone de checkpoint (luz suave ou brilho azul);
  - Caixa de texto: translúcida, pixelada, com bordas suaves (aparece no canto superior esquerdo, exibe frases curtas (3–4 segundos), com fonte Press Start 2P (ou similar), 8px, cor branca com sombra leve).

### 5.5. Paleta de Cores
- *Ecos do Silêncio:* azuis pálidos, areia fria, brancos suaves e cinzas suaves.  
- *Ruínas do Oceano:* tons frios, contraste alto, saturação abaixada.  
- *Horizonte de Esperança:* tons quentes (dourado, verde suave), saturação aumenta progressivamente.

---

## 6. Áudio

### 6.1. Trilha Sonora
- Trilha adaptativa com camada: 
  - Layer calmo, layer tensão, layer esperança — conforme FSM.
    
### 6.2. Efeitos Sonoros
- Por ação: passo na areia, splash, pulo, coletar item, usar item, ambiente (vento, chuva);
- Sons de feedback (por exemplo, ping ao coletar).

### 6.3. Dublagem
- Não há dublagem; a fala é expressa em texto curto.

---

## 7. Progresso e Salvamento

### 7.1. Sistema de Progressão
- O progresso é representado por posição no mapa (x coordinate contínua) + inventário (itens coletados).  
- Requisitos para eventos (por exemplo, abrir rocha final) checados via inventário e estado atual da FSM.

### 7.2. Sistema de Salvamento
- Salvamento automático em checkpoints (arquivo local JSON).  
  - Dados salvos: posição do checkpoint, itens coletados, estado atual das conchas, progresso de narrativa.  
- Opção de reiniciar nível/voltar ao menu.

---

## 8. Monetização

### 8.1. Modelo de Negócio
- Sem monetização.  

### 8.2. Itens Pagos
- Não aplicável.

---

## 9. Testes e Qualidade

### 9.1. Testes de Jogo
- **Testes Unitários (técnicos):** FSM transitions, validação de eventos;  
- **Testes de Integração:** troca de estados altera cenários, trilha e spawn;  
- **Playtests:** ~5 jogadores (testes de compreensão narrativa e dificuldade).  

### 9.2. Feedback dos Jogadores
- Coleta via formulário;
- Métricas: compreensão narrativa (percentual que reconhece mudança), taxa de conclusão, taxa de repetição de checkpoints.

---
