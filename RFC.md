# Ichigo: Memórias do Oceano (Godot)

- **Título do Projeto**: Desenvolvimento do jogo 2D “Ichigo: Memórias do Oceano” com motor narrativo baseado em Máquinas de Estados Finitos e Estrutura de Dados.
- **Nome do Estudante**:  Ana Carolina Fanhani Stralioti.
- **Curso**: Engenharia de Software.

# Resumo

Este trabalho trata do desenvolvimento do projeto de portfólio “Ichigo: Memórias do Oceano”, um jogo 2D que narra a jornada simbólica de uma criança sobrevivente a um tsunami. O projeto tem como objetivo central, além da criação do jogo, o desenvolvimento de um motor narrativo baseado em Máquinas de Estados Finitos (FSM), implementadas por meio de estruturas de dados. Esse motor permitirá modificar dinamicamente cenários, obstáculos e trilha sonora, conduzindo a história de forma adaptativa e resultando em uma narrativa orientada a estados, em contraste com uma progressão linear fixa. Desenvolvido na engine Godot, utilizando GDScript, o entregável definido para este projeto é a primeira fase “Ecos do Silêncio” que representa o momento imediatamente posterior ao desastre, introduzindo a coleta de memórias e dando um contexto de tudo o que pode ter sido perdido com o tsunami. O resultado é um jogo funcional, com um motor narrativo que possibilite o controle de estados ambientais e a criação de experiências interativas mais imersivas. 

## 1. Introdução

- **Contexto**: O mercado de jogos digitais vem se expandindo e, segundo Gregory (2009, apud Miranda, 2014), jogos digitais podem ser definidos como softwaes que criam mundos virtuais onde o jogador pode controlar um personagem, interagindo com o ambiente e outros personagens (sejam eles controlados por pessoas ou pelo próprio computador). Jogos que exploram histórias emocionais têm atraído atenção crescente, mas ainda são majoritariamente baseados em progressões lineares e estáticas. O uso de máquinas de estados finitos (FSM) e estruturas de dados oferece meios de criar narrativas mais dinâmicas, adaptativas e imersivas; segundo Mellington e Funge (2009, apud Miranda, 2014), uma FSM consiste em um conjunto de estados finitos e regras de transição que determinam mudanças de estado com base em condições específicas, sendo representável por diagramas de grafos, por exemplo. Além disso, Schwab (2009, apud Miranda, 2014) e Buckland (2004, apud Miranda, 2014) destacam que as FSMs são amplamente utilizadas em jogos digitais devido à sua simplicidade, rapidez de execução e flexibilidade, características que favorecem o desenvolvimento de narrativas não lineares.
- **Justificativa**: O projeto é relevante para a Engenharia de Software por propor um motor narrativo que, além explorar boas práticas de modelagem (FSM), aborda conceitos fundamentais (estruturas de dados, controle de estados), além de tratar o desenvolvimento de jogos, integrando-os em uma aplicação prática de impacto cultural e social.
- **Objetivos**: 
  - **Objetivo principal**: Desenvolver uma fase de i, jogo 2D com motor narrativo baseado em FSM e estruturas de dados, aplicado em uma história simbólica de sobrevivência e superação.
  - **Objetivo secundários**:
    - Criar uma FSM capaz de modificar dinamicamente ambientes e obstáculos;
    - Utilizar estrutura de dados no controle de estados narrativos.

## 2. Descrição do Projeto

* **Linha de Projeto**: Jogos Digitais.
* **Tema do Projeto**: Desenvolvimento de um jogo 2D com motor narrativo dinâmico baseado em FSM e estruturas de dados.
* **Propósito e Uso Prático**: O projeto busca resolver a limitação de narrativas lineares em jogos digitais, oferecendo uma solução em que o ambiente responde dinamicamente ao estado atual do jogo.
* **Público-Alvo**: Jogadores de jogos independentes (indie), estudantes e pesquisadores de game design.
* **Problemas a Resolver**: 
  * Limitação de narrativas estáticas em jogos;
  * Pouca exploração de FSM e estruturas de dados em motores narrativos.
* **Diferenciação/Ineditismo**: O projeto não apenas conta com uma fase de um jogo, mas também um motor narrativo baseado em FSM e estruturas de dados, diferente de jogos que vinculam emoções apenas a cutscenes, aqui o ambiente inteiro responde em tempo real às transições de estado.
* **Limitações**: 
  * O jogo conta com apenas uma fase e foco em narrativa simbólica, não abrangendo progressões extensas;
  * O motor narrativo foi validado em um protótipo 2D.
* **Normas e Legislações Aplicáveis**: 
  * ESRB/PEGI: classificação indicativa "Livre";
  * LGPD: não se aplica, pois o jogo não coleta dados pessoais;
  * WCAG: foram consideradas boas práticas de acessibilidade (contraste de cores e legendas de textos narrativos).
* **Métricas de Sucesso**: 
  * Funcionamento correto da FSM;
  * Clareza na correspondência entre estado ambiental e ambiente apresentado.
  * 
## 3. Especificação Técnica

### 3.1. Requisitos de Software
- **Requisitos Funcionais (RF)**:
  - RF01 - Controle de personagem: O jogador poderá mover Ichigo (andar, correr, pular e interagir com objetos); - Requisito atingido.
  - RF02 - Sistema de coleta:	O jogador poderá coletar conchas e objetos interativos (pá, balde, foto); - Requisito atingido.
  - RF03 - Sistema de estados ambientais (FSM):	O jogo deverá alterar o ambiente e obstáculos; - Requisito atingido.
  - RF04 - Sistema de checkpoints: O jogo deverá registrar pontos de salvamento ao longo do mapa; - Requisito atingido.
  - RF05 - Interações com o ambiente:	O jogador poderá preencher buracos ou ativar elementos com itens coletados; - Requisito atingido.
  - RF06 - HUD e interface: O jogo deverá exibir um contador de colecionáveis (conchas, imagens), item ativo e frases narrativas curtas; - Requisito atingido.
  - RF07 - Sistema de narrativa dinâmica:	O jogo deverá apresentar textos e eventos conforme a progressão dos estados da FSM; - Requisito atingido.
- **Requisitos Não-Funcionais (RNF)**:
  - RNF01	- Usabilidade:	Interface minimalista e intuitiva, sem necessidade de tutoriais externos; - Requisito atingido.
  - RNF02 -	Portabilidade: O jogo deverá ser executável em sistemas Windows (Godot export templates); - Requisito atingido.
  - RNF03 -	Segurança:	Não há coleta de dados, o projeto deverá seguir boas práticas de manipulação de arquivos e integridade de save; - Requisito atingido.
  - RNF04 -	Acessibilidade: Uso de cores contrastantes e fontes legíveis em tela; - Requisito atingido.
  - RNF05 -	Armazenamento local:	Checkpoints e progresso salvos em arquivo JSON local. - Requisito atingido.
  - 
- **Representação dos Requisitos**: Conforme Diagrama de Casos de Uso (UML)



- **Aderência aos Requisitos da Linha de Projeto**: O projeto “Ichigo: Memórias do Oceano” foi planejado para atender integralmente aos requisitos obrigatórios da linha de projeto Jogos Digitais, conforme descrito no regulamento de desenvolvimento de Portfólio. Cada item foi considerado desde a concepção do design até a implementação técnica na engine Godot. A fase criada é funcional, permitindo ao jogador iniciar, jogar e concluir a jogada. A progressão é controlada por uma Máquina de Estados Finitos (FSM) que regula transições ambientais e eventos narrativos. Também, o jogo foi exportado a partir da Godot em formato executável (.exe) para Windows e está hospedado no itch.io. Todo o código está mantido neste repositório, cumprindo o requisito de transparência e rastreabilidade do código. Além disso, contém, também, com uma Documentação com foco em Game Design, apresentando o personagem controlável (Ichigo) com movimentação, salto e interação, as regras e objetivos claros (coletar conchas entre outros objetos para avançar); o HUD funcional (contador de colecionáveis e item equipado) e menus simples. Embora o foco principal seja o motor narrativo, o jogo utiliza pixel art original criada no Aseprite. Os assets visuais e sonoros seguem licenças Creative Commons BY-NC-SA 4.0 e representam o estilo artístico proposto.

### 3.2. Considerações de Design
- **Padrões de Arquitetura**: Utilização de uma Finite State Machine (FSM) para controle ambiental, permitindo que o jogo altere dinamicamente seus estados de acordo com o progresso narrativo;
- **Decisões e Alternativas Consideradas**: Entre as engines avaliadas — Unity (C#) e Godot (GDScript) — optou-se pela Godot devido à leveza, ao código aberto (open source) e à curva de aprendizado mais acessível. Quanto à implementação da FSM, escolheu-se desenvolver uma solução própria com estruturas de dados, em vez de utilizar um plugin, visando maior flexibilidade, aprendizado técnico e possibilidade de reuso. Por fim, decidiu-se pela abordagem 2D em pixel art, em vez de 3D, considerando a viabilidade de produção de assets e o foco no design ambiental.
- **Critérios de Escalabilidade, Resiliência e Segurança**:
  - Escalabilidade: cada subsistema (FSM, Itens, UI, Áudio) é independente e testável, permitindo evolução modular;
  - Resiliência: caso um módulo falhe, o jogo deve continuar sua execução; se uma transição de estado não existir, o sistema deve permanecer no estado atual e registrar um aviso em log;
  - Segurança: os dados devem ser persistidos localmente, além de o jogo não coletar dados pessoais, apenas telemetria local opcional (como tempo de fase e itens coletados). 

### 3.3. Stack Tecnológica
- **Linguagens de Programação**: 
  - GDScript (Godot Engine): Linguagem de script nativa da Godot, de sintaxe simples e otimizada para desenvolvimento de jogos 2D. A escolha se justifica pela curva de aprendizado acessível e pela integração direta com os recursos da engine.
- **Frameworks e Bibliotecas**: 
  - Godot Engine: Engine de código aberto voltada para jogos 2D/3D, escolhida pelo suporte nativo a FSM, facilidade de exportação para Windows e comunidade ativa;
  - GUT (Godot Unit Testing): Framework de testes unitários para GDScript, utilizado para validar a FSM, inventário, save/load e geração de áudio procedural;
  - AudioStreamWAV / AudioStreamGenerator (nativos Godot): Todo o áudio do jogo é gerado proceduralmente em tempo real via a classe estática `ProceduralSFX`, sem arquivos de áudio externos.
- **Ferramentas de Desenvolvimento e Gestão**: 
  - IDE Godot Editor: Ambiente oficial de desenvolvimento do jogo;
  - Versionamento com Git + GitHub: Controle de versão para colaboração, rastreamento de mudanças e integração contínua;
  - Ferramenta gráfica Aseprite: Criação de sprites, concept art e backgrounds 2D.
- **Licenciamento**:  
  - **Código do Jogo**: Licenciado sob a [Licença MIT](https://opensource.org/licenses/MIT);
  - **Godot Engine**: Licenciada sob a [Licença MIT](https://opensource.org/licenses/MIT); 
  - **Arte e Assets Originais (sprites, cenários, personagens)**: Licenciados sob **Creative Commons BY-NC-SA 4.0** ([link](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.pt_BR)).  
  - **Áudio e Efeitos Sonoros**:  
    - Trilhas originais: Creative Commons licenciados sob **Creative Commons BY-NC-SA 4.0** ([link](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.pt_BR)).

### 3.4. Considerações de Segurança
- **Riscos Identificados**: 
  - Vazamento ou uso indevido de assets de terceiros (arte, sons, addons);
  - Inclusão de código malicioso em bibliotecas externas ou addons da comunidade Godot;
  - Distribuição do jogo sem clareza de licenciamento, permitindo uso indevido.
- **Medidas de Mitigação**: 
  - Utilização apenas de assets originais ou com licenças compatíveis;
  - Validação de entrada em FSM e eventos (checagem de estados válidos, limites de movimentação e colisões);
  - Inclusão explícita de Licenciamento no repositório e no jogo.
- **Normas e Boas Práticas Seguidas**: Boas práticas de versionamento para manter histórico confiável e rastreabilidade de código.
- **Responsabilidade Ética**: 
  - O jogo não coleta nem processa dados sensíveis;
  - A temática (tragédia natural) será tratada com cuidado narrativo, buscando inspiração simbólica sem exploração sensacionalista.
  - Todo o material será disponibilizado para fins acadêmicos e não comerciais, respeitando licenciamento aberto e princípios de uso responsável de tecnologia.

### 3.5. Conformidade e Normas Aplicáveis
- LGPD – Lei Geral de Proteção de Dados (Brasil, 2018):
  - O jogo não coleta nem armazena dados pessoais de usuários;
- Direitos Autorais e Licenciamento de acordo com a Lei nº 9.610/1998 (Brasil, 1998):
  - Todos os assets gráficos, sonoros e de código serão de autoria própria ou utilizados sob licenças abertas compatíveis;
- Classificação Indicativa de acordo com ESRB/PEGI adaptada ao Brasil – Portaria nº 368/2014 do Ministério da Justiça (Brasil, 2014):
  - O jogo não contém violência explícita, discurso de ódio ou elementos impróprios;
  - Pela narrativa simbólica, enquadra-se em classificação Livre.
   
## 4. Resultados e Próximos Passos

### 4.1. O que foi entregue (Fase 1 — concluída)

A Fase 1 “Ecos do Silêncio” foi implementada e exportada para Windows (.exe), hospedada no itch.io. Todos os marcos planejados foram concluídos:

  - Assets visuais criados no Aseprite (sprites, cenário, HUD, overlays);
  - Telas principais implementadas: menu inicial com 3 slots de save, HUD com inventário de 8 slots, menu de pausa com confirmação;
  - FSM narrativa com 5 estados (INICIO → RECONHECIMENTO → LEMBRANCA → CONFRONTO → RESOLUCAO), com transições de clima, narrativa e detritos;
  - Testes de jogabilidade realizados com 4 participantes via formulário (75% perceberam mudança de clima sem instrução);
  - Documentação técnica completa (RFC, GDD, Documentação Técnica, README);
  - Sistema de save/load com 3 slots independentes em JSON local;
  - Cutscene de tsunami;
  - Testes automatizados com GUT (85 testes em 5 arquivos cobrindo FSM, inventário, áudio, save e coletáveis).

### 4.2. Próximos Passos

  - Implementar a Fase 2 — “Ruínas do Oceano” (atualmente placeholder);
  - Implementar a Fase 3 — “Horizonte de Esperança”.

## 5. Referências

BRASIL. <strong>Lei n. 13.709, de 14 de agosto de 2018</strong>. Dispõe sobre a proteção de dados pessoais e altera a Lei n. 12.965, de 23 de abril de 2014 (Marco Civil da Internet). Diário Oficial da União : seção 1, Brasília, DF, ano 155, n. 157, p. 59-64, 15 ago. 2018. Disponível em: https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/L13709.htm. Acesso em: 20 set. 2025.

BRASIL. <strong>Lei n. 9.610, de 19 de fevereiro de 1998</strong>. Altera, atualiza e consolida a legislação sobre direitos autorais e dá outras providências. Diário Oficial da União: seção 1, Brasília, DF, ano 137, n. 40, p. 5-10, 20 fev. 1998. Disponível em: [https://www.planalto.gov.br/ccivil_03/leis/l9610.htm](https://www.planalto.gov.br/ccivil_03/leis/l9610.htm). Acesso em: 20 set. 2025.

BRASIL. Ministério da Justiça. Portaria n.º 368, de 11 de fevereiro de 2014. Diário Oficial da União: seção 1, Brasília, DF, ano 151, n.º 31, p. 4-5, 12 fev. 2014. Disponível em: [https://anttlegis.antt.gov.br/action/ActionDatalegis.php?acao=detalharAto&tipo=POR&numeroAto=00000368&seqAto=000&valorAno=2014&orgao=MJ&nomeTitulo=codigos&desItem=&desItemFim=&cod_modulo=420&cod_menu=7145](https://anttlegis.antt.gov.br/action/ActionDatalegis.php?acao=detalharAto&tipo=POR&numeroAto=00000368&seqAto=000&valorAno=2014&orgao=MJ&nomeTitulo=codigos&desItem=&desItemFim=&cod_modulo=420&cod_menu=7145). Acesso em: 20 set. 2025.

MIRANDA, Lucas Vieira de. <strong>Aplicação de máquina de estados em jogos digitais</strong>. 2014.
