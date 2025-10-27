# Capa

- **Título do Projeto**: Desenvolvimento do jogo 2D “Ichigo: Memórias do Oceano” com motor narrativo baseado em Máquinas de Estados Finitos e Estrutura de Dados.
- **Nome do Estudante**:  Ana Carolina Fanhani Stralioti.
- **Curso**: Engenharia de Software.
- **Data de Entrega**: [Data].

# Resumo

Este trabalho compõe a proposta de portfólio "Ichigo: Memórias do Oceano", um jogo 2D que narra a jornada simbólica de uma criança sobrevivente a um tsunami. O projeto tem como objetivo central o desenvolvimento de um motor narrativo baseado em Máquinas de Estados Finitos (FSM), implementadas a partir do uso de estruturas de dados. Esse motor permitirá modificar dinamicamente cenários, obstáculos e trilha sonora para conduzir a história, resultando em uma narrativa baseada em estados, o que supera uma progressão linear fixa. Desenvolvido na engine Godot, utilizando GDScript, o jogo é estruturado em três fases distintas: a primeira, “Ecos do Silêncio", representa o momento logo após o desastre, introduzindo o impacto inicial e a coleta de memórias; a segunda, "Ruínas do Oceano", transforma o ambiente em um cenário que apresenta a devastação concreta após a tragédia; e a terceira, "Horizonte de Esperança", mostra a tempestade passando, sendo uma fase de reconstrução e reencontro. O resultado esperado é não apenas um jogo funcional, mas um motor narrativo que facilite o controle de estados ambientais. A narrativa se encerra a criança avistando sua casa e seus pais à distância. 

## 1. Introdução

- **Contexto**: O mercado de jogos digitais vem se expandindo e, segundo Gregory (2009, apud Miranda, 2014), jogos digitais podem ser definidos como softwaes que criam mundos virtuais onde o jogador pode controlar um personagem, interagindo com o ambiente e outros personagens (sejam eles controlados por pessoas ou pelo próprio computador). Jogos que exploram histórias emocionais têm atraído atenção crescente, mas ainda são majoritariamente baseados em progressões lineares e estáticas. O uso de máquinas de estados finitos (FSM) e estruturas de dados oferece meios de criar narrativas mais dinâmicas, adaptativas e imersivas; segundo Mellington e Funge (2009, apud Miranda, 2014), uma FSM consiste em um conjunto de estados finitos e regras de transição que determinam mudanças de estado com base em condições específicas, sendo representável por diagramas de grafos, por exemplo. Além disso, Schwab (2009, apud Miranda, 2014) e Buckland (2004, apud Miranda, 2014) destacam que as FSMs são amplamente utilizadas em jogos digitais devido à sua simplicidade, rapidez de execução e flexibilidade, características que favorecem o desenvolvimento de narrativas não lineares.
- **Justificativa**: O projeto é relevante para a Engenharia de Software por propor um motor narrativo que, além explorar boas práticas de modelagem (FSM), aborda conceitos fundamentais (estruturas de dados, controle de estados), integrando-os em uma aplicação prática de impacto cultural e social.
- **Objetivos**: 
  - **Objetivo principal**: Desenvolver um jogo 2D com motor narrativo baseado em FSM e estruturas de dados, aplicado em uma história simbólica de sobrevivência e superação.
  - **Objetivo secundários**:
    - Criar uma FSM capaz de modificar dinamicamente ambientes, obstáculos e trilhas sonoras;
    - Utilizar estrutura de dados no controle de estados narrativos;
    - Desenvolver três fases contínuas.

## 2. Descrição do Projeto

* **Linha de Projeto**: Jogos Digitais.
* **Tema do Projeto**: Desenvolvimento de um jogo 2D com motor narrativo dinâmico baseado em FSM e estruturas de dados.
* **Propósito e Uso Prático**: O projeto busca resolver a limitação de narrativas lineares em jogos digitais, oferecendo uma solução em que o ambiente responde dinamicamente ao estado atual do jogo.
* **Público-Alvo**: Jogadores de jogos independentes (indie), estudantes e pesquisadores de game design, além de desenvolvedores interessados em narrativas interativas e motores narrativos.
* **Problemas a Resolver**: 
  * Limitação de narrativas estáticas em jogos;
  * Pouca exploração de FSM e estruturas de dados em motores narrativos.
* **Diferenciação/Ineditismo**: O projeto não apenas desenvolve um jogo, mas também um motor narrativo baseado em FSM e estruturas de dados, diferente de jogos que vinculam emoções apenas a cutscenes, aqui o ambiente inteiro responde em tempo real às transições de estado.
* **Limitações**: 
  * O jogo contará apenas três fases e foco em narrativa simbólica, não abrangendo progressões extensas;
  * O motor narrativo será validado em um protótipo 2D, não em ambientes 3D.
* **Normas e Legislações Aplicáveis**: 
  * ESRB/PEGI: classificação indicativa (previsto como "Livre").
  * LGPD: não se aplica diretamente, pois o jogo não coleta dados pessoais.
  * WCAG: serão consideradas boas práticas de acessibilidade (por exemplo, contraste de cores, legendas de textos narrativos).
* **Métricas de Sucesso**: 
  * Funcionamento correto da FSM (sem transições inválidas);
  * Clareza na correspondência entre estado ambiental e ambiente apresentado;
  * Avaliação de jogabilidade com usuários (entendimento da narrativa).

## 3. Especificação Técnica

### 3.1. Requisitos de Software
- **Requisitos Funcionais (RF)**:
  - RF01 - Controle de personagem: O jogador poderá mover Ichigo (andar, correr, pular e interagir com objetos);
  - RF02 - Sistema de coleta:	O jogador poderá coletar conchas e objetos interativos (pá, balde, foto);
  - RF03 - Sistema de estados ambientais (FSM):	O jogo deverá alterar o ambiente, trilha sonora e obstáculos de acordo com a fase;
  - RF04 - Sistema de checkpoints: O jogo deverá registrar pontos automáticos de salvamento ao longo do mapa;
  - RF05 - Interações com o ambiente:	O jogador poderá empurrar objetos, preencher buracos, escalar ou ativar elementos com itens coletados;
  - RF06 - HUD e interface: O jogo deverá exibir um contador de colecionáveis, item ativo e frases narrativas curtas;
  - RF07 - Sistema de narrativa dinâmica:	O jogo deverá apresentar textos e eventos conforme a progressão dos estados da FSM;
  - RF08 - Sistema de som adaptativo: A trilha sonora e os efeitos sonoros deverão reagir às mudanças de estado.
- **Requisitos Não-Funcionais (RNF)**:
  - RNF01	- Usabilidade:	Interface minimalista e intuitiva, sem necessidade de tutoriais externos;
  - RNF02 -	Portabilidade: O jogo deverá ser executável em sistemas Windows (Godot export templates);
  - RNF03	- Escalabilidade: O motor FSM e o sistema de itens devem ser modulares para reutilização em novos jogos;
  - RNF04 -	Segurança:	Não há coleta de dados; o projeto deverá seguir boas práticas de manipulação de arquivos e integridade de save.
  - RNF05 -	Acessibilidade: Uso de cores contrastantes e fontes legíveis em tela;
  - RNF06 -	Armazenamento local:	Checkpoints e progresso salvos em arquivo JSON local.
- **Representação dos Requisitos**: Inclua um Diagrama de Casos de Uso (UML)

- **Aderência aos Requisitos da Linha de Projeto**: O projeto “Ichigo: Memórias do Oceano” foi planejado para atender integralmente aos requisitos obrigatórios da linha de projeto Jogos Digitais, conforme descrito no regulamento do desenvolvimento de Portfólio. Cada item foi considerado desde a concepção do design até a implementação técnica na engine Godot. O protótipo será funcional, com três fases contínuas (Ecos do Silêncio, Ruínas do Oceano e Horizonte de Esperança), permitindo ao jogador iniciar, jogar e concluir a jornada sem interrupções. A progressão será controlada por uma Máquina de Estados Finitos (FSM) que regula transições ambientais e eventos narrativos, garantindo um loop completo de gameplay do início ao fim. Também, o jogo será exportado a partir da Godot em formato executável (.exe) e WebGL, permitindo execução local ou online, enquanto a versão WebGL será hospedada no itch.io para testes públicos e demonstração durante o simpósio. Todo o código será mantido neste repositório, cumprindo o requisito de transparência e rastreabilidade do código. Além disso, contará, também, com uma Documentação com foco em Game Design completo, apresentando o personagem controlável (Ichigo) com movimentação, salto e interação, as regras e objetivos claros (coletar conchas e objetos para avançar); a condição de vitória (reencontro final com os pais); o HUD funcional (contador de colecionáveis e item equipado); menus simples e feedback sonoro. Embora o foco principal seja o motor narrativo, o jogo utiliza pixel art original criada no Aseprite e trilhas sonoras dinâmicas baseadas em estados ambientais.
Os assets visuais e sonoros seguem licenças Creative Commons BY-NC-SA 4.0 e representam fielmente o estilo artístico e emocional proposto.

### 3.2. Considerações de Design
- **Visão Inicial da Arquitetura**: Apresente os principais componentes e suas interações.
- **Padrões de Arquitetura**: Informe padrões adotados (ex.: [MVC](https://en.wikipedia.org/wiki/Model–view–controller), [Microserviços](https://microservices.io/), [MVVM](https://en.wikipedia.org/wiki/Model–view–viewmodel), Arquitetura em Camadas).
- **Mockups das Telas Principais**: Apresente protótipos visuais das telas mais relevantes, mostrando navegação, disposição de elementos e principais interações do usuário. Esses mockups podem ser feitos em ferramentas como Figma, Adobe XD ou similares, e devem refletir a identidade visual e usabilidade prevista para o produto.
- **Decisões e Alternativas Consideradas**: Justifique escolhas de design, documentando alternativas avaliadas.
- **Critérios de Escalabilidade, Resiliência e Segurança**: Descreva como a solução será projetada para suportar crescimento, lidar com falhas e manter segurança.

### 3.3. Stack Tecnológica
- **Linguagens de Programação**: 
  - GDScript (Godot Engine): Linguagem de script nativa da Godot, de sintaxe simples e otimizada para desenvolvimento de jogos 2D. A escolha se justifica pela curva de aprendizado acessível e pela integração direta com os recursos da engine.
  - Python (opcional – prototipagem e testes de FSM): Pode ser utilizado em protótipos de FSM e simulação de estruturas de dados antes da implementação final em GDScript.
- **Frameworks e Bibliotecas**: 
  - Godot Engine 4.x: Engine de código aberto voltada para jogos 2D/3D, escolhida pelo suporte nativo a FSM, facilidade de exportação multiplataforma e comunidade ativa.
  - Biblioteca Godot State Machine (addons): Biblioteca open source que fornece templates para criação de Máquinas de Estados Finitos, acelerando a implementação do motor narrativo.
  - FMOD ou Godot Audio Server: Para manipulação de áudio dinâmico, permitindo alterar trilhas sonoras conforme os estados narrativos.
- **Ferramentas de Desenvolvimento e Gestão**: 
  - IDE: Godot Editor: Ambiente oficial de desenvolvimento do jogo.
  - Versionamento: Git + GitHub/GitLab: Controle de versão para colaboração, rastreamento de mudanças e integração contínua.
  - Kanban (GitHub Projects/Trello): Organização do fluxo de tarefas.
  - Ferramentas gráficas: Krita / Aseprite / GIMP: Criação de sprites, concept art e backgrounds 2D
- **Licenciamento**:  
  - **Código do Jogo (Ichigo: Memórias do Oceano)**: Licenciado sob a [Licença MIT](https://opensource.org/licenses/MIT).  
  - **Godot Engine**: Licenciada sob a Licença MIT (código aberto).  
  - **Addons e Bibliotecas de Terceiros**: Seguem suas respectivas licenças (MIT/GPL/Apache), especificadas na pasta `addons/` quando aplicável.  
  - **Arte e Assets Originais (sprites, cenários, personagens)**: Licenciados sob **Creative Commons BY-NC-SA 4.0** ([link](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.pt_BR)).  
  - **Áudio e Efeitos Sonoros**:  
    - Trilhas originais: Creative Commons BY-NC-SA 4.0.

### 3.4. Considerações de Segurança
- **Riscos Identificados**: 
  - Vazamento ou uso indevido de assets de terceiros (arte, sons, addons);
  - Inclusão de código malicioso em bibliotecas externas ou addons da comunidade Godot;
  - Distribuição do jogo sem clareza de licenciamento, permitindo uso indevido.
- **Medidas de Mitigação**: 
  - Utilização apenas de assets originais ou com licenças compatíveis;
  - Validação de entrada em FSM e eventos (checagem de estados válidos, limites de movimentação e colisões).
  - Inclusão explícita de Licenciamento no repositório e no jogo.
- **Normas e Boas Práticas Seguidas**: Boas práticas de versionamento (Git) para manter histórico confiável e rastreabilidade de código.
- **Responsabilidade Ética**: 
  - O jogo não coleta nem processa dados sensíveis;
  - A temática (tragédia natural) será tratada com cuidado narrativo, buscando inspiração simbólica sem exploração sensacionalista.
  - Todo o material será disponibilizado para fins acadêmicos e não comerciais, respeitando licenciamento aberto e princípios de uso responsável de tecnologia.

### 3.5. Conformidade e Normas Aplicáveis
- Relacione todas as legislações, regulamentações e normas técnicas aplicáveis ao projeto, descrevendo brevemente como serão atendidas.
- Exemplos:
  - [LGPD – Lei Geral de Proteção de Dados](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/L13709.htm):
    - O jogo não coleta nem armazena dados pessoais de usuários;
  - Direitos Autorais e Licenciamento (Lei nº 9.610/1998 e Creative Commons):
    - Todos os assets gráficos, sonoros e de código serão de autoria própria ou utilizados sob licenças abertas compatíveis.
  - Classificação Indicativa (ESRB/PEGI adaptada ao Brasil – Portaria nº 368/2014 do Ministério da Justiça):
    - O jogo não contém violência explícita, discurso de ódio ou elementos impróprios.
    - Pela narrativa simbólica, enquadra-se em classificação Livre.
   
## 4. Próximos Passos

 - Descrição dos passos seguintes após a conclusão do documento, com uma visão geral do cronograma para Portfólio I e II.
 - Definição de Marcos: Estabelecer datas para entregas intermediárias e checkpoints.

## 5. Referências

MIRANDA, Lucas Vieira de. <strong>Aplicação de máquina de estados em jogos digitais</strong>. 2014.

## 6. Apêndices
